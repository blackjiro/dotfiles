#!/usr/bin/env -S deno run --allow-run

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Add Project Draft
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 📝
// @raycast.packageName GitHub Projects
// @raycast.argument1 { "type": "text", "placeholder": "タイトル" }
// @raycast.argument2 { "type": "text", "placeholder": "コメント（任意）", "optional": true }

// Documentation:
// @raycast.description GitHub Projectsにドラフトアイテムを追加
// @raycast.author blackjiro

const GITHUB_USER = "blackjiro";
const PROJECT_NUMBER = 4;

async function getProjectId(): Promise<string> {
  const query = `
    query {
      user(login: "${GITHUB_USER}") {
        projectV2(number: ${PROJECT_NUMBER}) {
          id
        }
      }
    }
  `;

  const cmd = new Deno.Command("gh", {
    args: ["api", "graphql", "-f", `query=${query}`],
    stdout: "piped",
    stderr: "piped",
  });

  const { stdout, stderr, success } = await cmd.output();
  if (!success) {
    throw new Error(new TextDecoder().decode(stderr));
  }

  const result = JSON.parse(new TextDecoder().decode(stdout));
  return result.data.user.projectV2.id;
}

async function createDraftIssue(
  projectId: string,
  title: string,
  body?: string
): Promise<void> {
  const mutation = `
    mutation($projectId: ID!, $title: String!, $body: String) {
      addProjectV2DraftIssue(input: {
        projectId: $projectId
        title: $title
        body: $body
      }) {
        projectItem {
          id
        }
      }
    }
  `;

  const args = [
    "api",
    "graphql",
    "-f",
    `query=${mutation}`,
    "-f",
    `projectId=${projectId}`,
    "-f",
    `title=${title}`,
  ];

  if (body) {
    args.push("-f", `body=${body}`);
  }

  const cmd = new Deno.Command("gh", {
    args,
    stdout: "piped",
    stderr: "piped",
  });

  const { stderr, success } = await cmd.output();
  if (!success) {
    throw new Error(new TextDecoder().decode(stderr));
  }
}

async function main() {
  const [title, body] = Deno.args;

  if (!title) {
    console.error("タイトルを入力してください");
    Deno.exit(1);
  }

  try {
    const projectId = await getProjectId();
    await createDraftIssue(projectId, title, body || undefined);
    console.log(`追加: ${title}`);
  } catch (error) {
    console.error(`エラー: ${error instanceof Error ? error.message : error}`);
    Deno.exit(1);
  }
}

main();
