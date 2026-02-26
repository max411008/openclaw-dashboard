#!/bin/bash
# 🔧 Mac 端狀態更新腳本
# 收集 OpenClaw 狀態並推送到 GitHub

set -e  # 遇到錯誤即停止

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 設定
REPO_URL="https://github.com/max411008/openclaw-dashboard.git"
LOG_FILE="$HOME/openclaw-workspaces/auto/logs/dashboard-update.log"
LOCK_FILE="/tmp/openclaw-dashboard-update.lock"

# 建立 log 目錄
mkdir -p "$(dirname "$LOG_FILE")"

# 防止重複執行
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "[$(date)] 另一個更新程序正在執行 (PID: $PID)，跳過" >> "$LOG_FILE"
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"

# 清理 lock 檔案的函數
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

echo "[$(date)] 開始更新 Dashboard 狀態..." >> "$LOG_FILE"

# ========== 收集狀態 ==========

echo "[$(date)] 收集 OpenClaw 狀態..." >> "$LOG_FILE"

# Gateway 狀態
GATEWAY_STATUS="offline"
GATEWAY_PORT="-"
GATEWAY_VERSION="-"
GATEWAY_UPTIME=0

if command -v openclaw &> /dev/null; then
    # 嘗試取得狀態
    if openclaw gateway status &> /dev/null; then
        GATEWAY_STATUS="online"
        GATEWAY_PORT="18889"
        GATEWAY_VERSION=$(openclaw --version 2>/dev/null | head -1 || echo "unknown")
        # 嘗試取得 uptime（簡化版，實際可能需要更複雜的邏輯）
        GATEWAY_UPTIME=3600  # 預設 1 小時，實際應該計算
    fi
fi

# 工具並行數（這裡需要根據實際情況調整）
# 目前使用預設值，實際可以透過分析 process 或其他方式取得
CONCURRENT_TOOLS=0
MAX_CONCURRENT=2
ACTIVE_SESSIONS=1

# 檢查是否有 running 的 subagent
if command -v openclaw &> /dev/null; then
    ACTIVE_SESSIONS=$(openclaw sessions list 2>/dev/null | grep -c "active" || echo "1")
    # 簡化：假設如果有 sessions 列表，至少有 1 個工具在使用
    if [ "$ACTIVE_SESSIONS" -gt 1 ]; then
        CONCURRENT_TOOLS=1
    fi
fi

# ========== 產生 status.json ==========

echo "[$(date)] 產生 status.json..." >> "$LOG_FILE"

cat > data/status.json << EOF
{
  "gateway": {
    "status": "$GATEWAY_STATUS",
    "port": $GATEWAY_PORT,
    "process": "openclaw-gateway",
    "version": "$GATEWAY_VERSION",
    "uptime": $GATEWAY_UPTIME
  },
  "resources": {
    "concurrent_tools": $CONCURRENT_TOOLS,
    "max_concurrent": $MAX_CONCURRENT,
    "active_sessions": $ACTIVE_SESSIONS
  },
  "tasks": {
    "pending": [],
    "running": [],
    "completed": []
  },
  "workers": {
    "supervisor": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "frontdesk": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "dev": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "auto": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "editor": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "research": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "opsdata": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" },
    "sre": { "status": "idle", "last_activity": "$(date -u +%Y-%m-%dT%H:%M:%SZ)" }
  },
  "last_update": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "[$(date)] status.json 已更新" >> "$LOG_FILE"

# ========== 推送到 GitHub ==========

echo "[$(date)] 推送到 GitHub..." >> "$LOG_FILE"

# 檢查是否有變更
if git diff --quiet data/status.json; then
    echo "[$(date)] 無變更，跳過推送" >> "$LOG_FILE"
    exit 0
fi

# 配置 git（如果還沒設定）
if ! git config user.email &> /dev/null; then
    git config user.email "dashboard@openclaw.local"
    git config user.name "Dashboard Bot"
fi

# 加入變更
git add data/status.json

# 提交
COMMIT_MSG="Update status: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1 || {
    echo "[$(date)] 提交失敗或無變更" >> "$LOG_FILE"
    exit 0
}

# 推送
git push origin main >> "$LOG_FILE" 2>&1

echo "[$(date)] ✅ 更新完成並推送到 GitHub" >> "$LOG_FILE"
echo "[$(date)] 網址: https://max411008.github.io/openclaw-dashboard" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
