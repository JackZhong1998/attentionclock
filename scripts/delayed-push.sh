#!/usr/bin/env bash
# 延迟 1 小时后自动提交并推送到 GitHub
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DELAY_SECONDS="${1:-3600}"
COMMIT_MSG="${2:-Add cat companion, localization, and UI improvements}"

echo "将在 ${DELAY_SECONDS} 秒（约 $((DELAY_SECONDS / 60)) 分钟）后提交并推送..."
echo "目标仓库: $(git remote get-url origin 2>/dev/null || echo 'unknown')"
echo "按 Ctrl+C 可取消"
sleep "$DELAY_SECONDS"

echo "开始提交..."
git add -A
git commit -m "$COMMIT_MSG" || { echo "没有新改动需要提交"; exit 0; }
git push origin HEAD
echo "完成！已推送到 GitHub。"
