# 🔧 OpenClaw 監控 Dashboard

一個離線可用的美觀監控 Dashboard，用於監控 OpenClaw 系統狀態。

## 📁 檔案結構

```
dashboard/
├── index.html          # Dashboard 主頁（單一 HTML，內嵌所有資源）
├── data/
│   └── status.json     # 狀態資料檔案
└── README.md           # 本文件
```

## 🚀 使用方式

### 1. 開啟 Dashboard

直接用瀏覽器開啟 `index.html`：

```bash
# macOS
open ~/openclaw-workspaces/dev/dashboard/index.html

# 或使用 Python 簡易伺服器（推薦，避免 CORS 問題）
cd ~/openclaw-workspaces/dev/dashboard
python3 -m http.server 8080
# 然後訪問 http://localhost:8080
```

### 2. 資料更新

Dashboard 會自動從 `data/status.json` 讀取資料。

**手動更新資料：**
直接編輯 `data/status.json` 檔案，Dashboard 會在下次刷新時顯示最新狀態。

### 3. 自動更新腳本範例

```bash
#!/bin/bash
# update-status.sh - 更新狀態檔案

STATUS_FILE="~/openclaw-workspaces/dev/dashboard/data/status.json"

# 取得 Gateway 狀態
GATEWAY_STATUS=$(openclaw gateway status 2>/dev/null || echo "offline")
UPTIME=$(ps -o etime= -p $(pgrep openclaw-gateway) 2>/dev/null || echo "0")

# 產生新的 status.json
cat > $STATUS_FILE << EOF
{
  "gateway": {
    "status": "$GATEWAY_STATUS",
    "port": 7331,
    "process": "openclaw-gateway",
    "version": "$(openclaw --version 2>/dev/null || echo 'unknown')",
    "uptime": $UPTIME
  },
  ...
}
EOF
```

## 📊 資料格式

### status.json 結構

```json
{
  "gateway": {
    "status": "online|offline",
    "port": 7331,
    "process": "process-name",
    "version": "x.x.x",
    "uptime": 86400
  },
  "resources": {
    "concurrent_tools": 1,
    "max_concurrent": 2,
    "active_sessions": 3
  },
  "tasks": {
    "pending": [...],
    "running": [...],
    "completed": [...]
  },
  "workers": {
    "supervisor": { "status": "active|idle|busy", "last_activity": "ISO timestamp" },
    "frontdesk": { ... },
    "dev": { ... },
    "auto": { ... },
    "editor": { ... },
    "research": { ... },
    "opsdata": { ... },
    "sre": { ... }
  },
  "last_update": "2026-02-27T04:32:15Z"
}
```

## 🎨 功能特色

- ✅ **完全離線** - 無外部 CDN 依賴
- ✅ **響應式設計** - 支援桌面、平板、手機
- ✅ **深色主題** - 適合長時間監控
- ✅ **自動刷新** - 每 30 秒自動更新
- ✅ **手動刷新** - 即時更新按鈕
- ✅ **視覺化狀態** - 進度條、狀態指示燈

## 🖥️ 介面說明

| 區塊 | 說明 |
|------|------|
| 🌐 Gateway | 顯示 Gateway 運行狀態、Port、版本、運行時間 |
| 📊 資源使用 | 顯示工具並行數、Active Sessions、使用率進度條 |
| 📋 任務看板 | 顯示待處理/進行中/已完成任務數量及列表 |
| 👥 Worker | 顯示 8 個角色的狀態（Supervisor、Dev、SRE 等） |

## 🔧 自訂設定

### 修改刷新間隔

編輯 `index.html` 中的 `REFRESH_SECONDS`：

```javascript
const REFRESH_SECONDS = 30;  // 改為 60 表示每分鐘刷新
```

### 新增 Worker 角色

在 `index.html` 的 `WORKER_ROLES` 陣列中加入新角色：

```javascript
const WORKER_ROLES = [
    { id: 'supervisor', name: 'Supervisor', emoji: '👑' },
    { id: 'mynewrole', name: 'MyNewRole', emoji: '🚀' },
    // ...
];
```

### 修改主題顏色

在 CSS `:root` 區塊中修改顏色變數：

```css
:root {
    --bg-primary: #0f172a;      /* 主背景色 */
    --accent-primary: #3b82f6;  /* 強調色 */
    --accent-success: #22c55e;  /* 成功色 */
    --accent-warning: #f59e0b;  /* 警告色 */
    --accent-danger: #ef4444;   /* 危險色 */
}
```

## 📝 注意事項

1. **CORS 限制**：直接用 `file://` 協議開啟可能無法載入 JSON，建議使用本機伺服器
2. **瀏覽器支援**：建議使用 Chrome、Firefox、Safari 最新版本
3. **資料安全**：`status.json` 包含敏感資訊時，請確保適當的存取控制

## 🐛 疑難排解

| 問題 | 解決方案 |
|------|----------|
| 資料無法載入 | 確認使用 http 伺服器而非直接開啟檔案 |
| 自動刷新停止 | 檢查瀏覽器控制台是否有錯誤訊息 |
| 樣式錯誤 | 清除瀏覽器快取後重試 |

---

**版本**: 1.0  
**更新日期**: 2026-02-27
