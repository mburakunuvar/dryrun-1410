---
agent: 'agent'
description: 'List GitHub issues for this repository with optional filters'
argument-hint: 'Optional: state (open/closed/all), label, or assignee'
---

List the GitHub issues for the current repository using the `gh` CLI.

By default, list **open** issues without prompting the user.

Infer optional filters directly from the user's message:
- If the user requests a different state, use that state (`open`, `closed`, or `all`).
- If the user requests a label filter, add `--label "<label>"`.
- If the user requests an assignee filter, add `--assignee "<username>"`.
- If no filter is requested, use only `--state open`.

Run the following command in the terminal:

```bash
gh issue list --state open --limit 50 --json number,title,state,labels,assignees,createdAt
```

- Do NOT prompt the user for these values.

After running the command, present the results as a Markdown table with these columns:

| # | Title | State | Labels | Assignee | Created |

Rules:
- Sort by most recently created first
- If a field is empty, show `—`
- Highlight any issues that are more than 30 days old with a ⚠️ prefix on the title
- After the table, show a brief summary: total count, how many are open vs closed
