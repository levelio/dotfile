#!/usr/bin/env node

import { spawnSync } from "node:child_process";

const shellEnvCache = new Map();

const systemPrompt = [
  "You write concise Conventional Commit messages.",
  "Return only the commit message text.",
  "Write the subject and body in Chinese.",
  "Keep Conventional Commit types such as feat, fix, docs, chore in lowercase English.",
  "Keep the subject line under 72 characters.",
  "Add a short body only when it adds useful context.",
  "Do not wrap the response in markdown.",
].join("\n");

function shellEnv(name) {
  if (!/^[A-Z_][A-Z0-9_]*$/.test(name)) {
    return undefined;
  }

  if (shellEnvCache.has(name)) {
    return shellEnvCache.get(name);
  }

  const start = "__NVIM_AI_ENV_START__";
  const end = "__NVIM_AI_ENV_END__";
  const result = spawnSync(
    "/bin/zsh",
    [
      "-dfc",
      `source "$HOME/.zshrc" >/dev/null 2>&1; printf '%s%s%s' '${start}' "$${name}" '${end}'`,
    ],
    {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
      timeout: 5000,
    },
  );

  let value;
  if (!result.error && typeof result.stdout === "string") {
    const from = result.stdout.lastIndexOf(start);
    const to = from === -1 ? -1 : result.stdout.indexOf(end, from + start.length);
    if (to !== -1) {
      value = result.stdout.slice(from + start.length, to).trim() || undefined;
    }
  }

  if (value) {
    process.env[name] = value;
  }

  shellEnvCache.set(name, value);
  return value;
}

function env(name) {
  const value = process.env[name];
  return value && value.trim() !== "" ? value.trim() : shellEnv(name);
}

function responsesUrl() {
  const explicitUrl = env("CODEX_RESPONSES_URL");
  if (explicitUrl) {
    return explicitUrl;
  }

  const baseUrl =
    env("CODEX_BASE_URL") ||
    env("CODEX_API_BASE") ||
    env("OPENAI_BASE_URL") ||
    env("OPENAI_API_BASE") ||
    "https://api.openai.com/v1";

  const trimmed = baseUrl.replace(/\/+$/, "");
  return trimmed.endsWith("/v1") ? `${trimmed}/responses` : `${trimmed}/v1/responses`;
}

function apiKey() {
  return env("CODEX_API_KEY") || env("OPENAI_API_KEY");
}

function model() {
  return env("CODEX_MODEL") || "gpt-5-mini";
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    ...options,
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    const stderr = (result.stderr || "").trim();
    const stdout = (result.stdout || "").trim();
    throw new Error(stderr || stdout || `${command} exited with code ${result.status}`);
  }

  return result.stdout || "";
}

function stagedDiff() {
  const diff = run("git", ["diff", "--no-ext-diff", "--staged"]);
  if (diff.trim() === "") {
    throw new Error("No staged changes found. Stage files in lazygit first.");
  }

  return diff;
}

function userPrompt(diff) {
  return `Generate one commit message for this staged git diff:\n\n\`\`\`diff\n${diff}\n\`\`\``;
}

function cleanCommitMessage(message) {
  return message
    .trim()
    .replace(/^```[\w-]*\s*/, "")
    .replace(/\s*```$/, "")
    .trim();
}

function extractError(payload, fallback, status) {
  if (payload && typeof payload === "object") {
    if (payload.error && typeof payload.error === "object" && payload.error.message) {
      return `HTTP ${status}: ${payload.error.message}`;
    }

    if (payload.error) {
      return `HTTP ${status}: ${String(payload.error)}`;
    }

    if (payload.message) {
      return `HTTP ${status}: ${String(payload.message)}`;
    }
  }

  return `HTTP ${status}: ${fallback.trim() || "request failed"}`;
}

function collectText(value, output) {
  if (!value) {
    return;
  }

  if (typeof value === "string") {
    output.push(value);
    return;
  }

  if (Array.isArray(value)) {
    for (const item of value) {
      collectText(item, output);
    }
    return;
  }

  if (typeof value !== "object") {
    return;
  }

  if (value.type === "output_text" && typeof value.text === "string") {
    output.push(value.text);
    return;
  }

  if (typeof value.output_text === "string") {
    output.push(value.output_text);
    return;
  }

  if (typeof value.content === "string") {
    output.push(value.content);
    return;
  }

  collectText(value.content, output);
  collectText(value.output, output);
  collectText(value.choices, output);
  collectText(value.message, output);
}

function extractCommitMessage(payload) {
  if (typeof payload?.output_text === "string" && payload.output_text.trim() !== "") {
    return cleanCommitMessage(payload.output_text);
  }

  const output = [];
  collectText(payload?.output, output);
  collectText(payload?.choices, output);

  return cleanCommitMessage(output.join("\n"));
}

function parseSseBlock(block) {
  const data = [];
  let event;

  for (const line of block.split(/\r?\n/)) {
    if (line.startsWith("event:")) {
      event = line.slice("event:".length).trim();
    } else if (line.startsWith("data:")) {
      data.push(line.slice("data:".length).trimStart());
    }
  }

  return {
    event,
    data: data.join("\n"),
  };
}

function extractStreamFailure(payload) {
  const error = payload?.error || payload?.response?.error;
  if (error && typeof error === "object" && error.message) {
    return error.message;
  }

  if (error) {
    return String(error);
  }

  if (payload?.message) {
    return String(payload.message);
  }

  if (payload?.response?.status_details?.error) {
    return String(payload.response.status_details.error);
  }

  return JSON.stringify(payload);
}

async function readStreamingCommitMessage(response) {
  if (!response.body) {
    throw new Error("Streaming response did not include a body.");
  }

  const decoder = new TextDecoder();
  const deltas = [];
  let completedMessage = "";
  let buffer = "";

  function handleBlock(block) {
    const { event, data } = parseSseBlock(block);
    if (!data || data === "[DONE]") {
      return;
    }

    let payload;
    try {
      payload = JSON.parse(data);
    } catch {
      return;
    }

    const type = payload.type || event;
    if (type === "response.output_text.delta" && typeof payload.delta === "string") {
      deltas.push(payload.delta);
      return;
    }

    if (type === "response.completed") {
      completedMessage = extractCommitMessage(payload.response || payload) || completedMessage;
      return;
    }

    if (type === "response.failed" || type === "error") {
      throw new Error(extractStreamFailure(payload));
    }
  }

  function drainBuffer() {
    let match;
    while ((match = buffer.match(/\r?\n\r?\n/))) {
      const block = buffer.slice(0, match.index);
      buffer = buffer.slice(match.index + match[0].length);
      handleBlock(block);
    }
  }

  for await (const chunk of response.body) {
    buffer += decoder.decode(chunk, { stream: true });
    drainBuffer();
  }

  buffer += decoder.decode();
  if (buffer.trim() !== "") {
    handleBlock(buffer);
  }

  return cleanCommitMessage(deltas.join("")) || completedMessage;
}

async function requestCommitMessage(diff) {
  const key = apiKey();
  if (!key) {
    throw new Error("Set CODEX_API_KEY or OPENAI_API_KEY before running this command.");
  }

  const response = await fetch(responsesUrl(), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${key}`,
    },
    body: JSON.stringify({
      model: model(),
      stream: true,
      store: false,
      instructions: systemPrompt,
      input: [
        {
          role: "user",
          content: userPrompt(diff),
        },
      ],
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    let payload;

    try {
      payload = text ? JSON.parse(text) : {};
    } catch {
      payload = undefined;
    }

    throw new Error(extractError(payload, text, response.status));
  }

  const message = await readStreamingCommitMessage(response);
  if (!message) {
    throw new Error("AI did not return a commit message.");
  }

  return message;
}

function copyToClipboard(message) {
  run("pbcopy", [], {
    input: message,
  });
}

try {
  const diff = stagedDiff();
  const message = await requestCommitMessage(diff);
  copyToClipboard(message);

  console.log("已复制到剪贴板：\n");
  console.log(message);
} catch (error) {
  console.error(`AI commit message failed: ${error.message}`);
  process.exit(1);
}
