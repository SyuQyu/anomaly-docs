#!/usr/bin/env bash
cd "$(dirname "$0")/.." || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
export GIT_TERMINAL_PROMPT=0
say() { printf '{"systemMessage":"anomaly-docs: %s"}\n' "$1"; }

if [ "$1" = "pull" ]; then
  if ! git pull --rebase --autostash -q >/dev/null 2>&1; then
    git rebase --abort >/dev/null 2>&1
    say "could not pull from GitHub (offline or conflict). Run git pull in CarRepairShop."
  fi
  exit 0
fi

git add -A
if ! git diff --cached --quiet; then
  files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
  who=$(git config user.name)
  git commit -q -m "Update ${files% }" -m "Auto-synced by ${who:-unknown} at $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1
fi

[ -z "$(git log @{u}..HEAD --oneline 2>/dev/null)" ] && exit 0

if ! git pull --rebase -q >/dev/null 2>&1; then
  git rebase --abort >/dev/null 2>&1
  say "a teammate changed the same lines; your commit is saved locally but NOT pushed. Ask Claude to merge and push."
  exit 0
fi
if git push -q >/dev/null 2>&1; then
  say "pushed to GitHub"
else
  say "push failed (login or permission). Run git push in CarRepairShop."
fi
exit 0
