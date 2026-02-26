# 📊 OpenClaw Dashboard - GitHub Pages 版

自動化監控儀表板，定時從 Mac 收集狀態並部署到 GitHub Pages。

## 🏗️ 架構說明

```
Mac (你的電腦)                          GitHub
├─ 定時執行收集腳本 (每 5 分鐘)          ├─ 倉庫: openclaw-dashboard
│  ├─ 讀取 OpenClaw 狀態                │  ├─ data/status.json (狀態資料)
│  ├─ 更新 status.json                  │  ├─ index.html (Dashboard)
│  └─ git push 到 GitHub                │  └─ GitHub Pages (公開網站)
│                                        │
└─ 本地 Dashboard (可選)                 └─ GitHub Actions (可選備援)
   └─ 離線查看用
```

## 📁 倉庫結構

```
openclaw-dashboard/
├── .github/
│   └── workflows/
│       └── update-status.yml    # GitHub Actions (備援)
├── data/
│   └── status.json              # 狀態資料檔案
├── index.html                   # Dashboard 主頁
├── update-local.sh              # Mac 端更新腳本
└── README.md                    # 說明文件
```

## 🚀 快速設定

### 1. 建立 GitHub 倉庫

```bash
# 在 GitHub 上建立新倉庫 (例如: openclaw-dashboard)
# 不要初始化 README，我們會從本地推送
```

### 2. 本地初始化並推送

```bash
cd ~/openclaw-workspaces/dev/dashboard

# 初始化 git
git init

# 建立 .gitignore
cat > .gitignore << 'EOF'
.DS_Store
*.log
node_modules/
EOF

# 加入所有檔案
git add .

# 提交
git commit -m "Initial dashboard with GitHub Pages support"

# 連結遠端倉庫 (替換成你的帳號)
git remote add origin https://github.com/YOUR_USERNAME/openclaw-dashboard.git

# 推送
git branch -M main
git push -u origin main
```

### 3. 啟用 GitHub Pages

1. 在 GitHub 倉庫頁面 → **Settings** → **Pages**
2. **Source** 選擇 **Deploy from a branch**
3. **Branch** 選擇 **main** → **/(root)**
4. 點擊 **Save**
5. 等待 1-2 分鐘，會顯示網址如：`https://YOUR_USERNAME.github.io/openclaw-dashboard`

### 4. 設定 Mac 定時更新

```bash
# 安裝 GitHub CLI (如果還沒安裝)
brew install gh

# 登入 GitHub
gh auth login

# 設定 cron (每 5 分鐘更新一次)
crontab -e

# 加入這一行：
*/5 * * * * cd ~/openclaw-workspaces/dev/dashboard && bash update-local.sh >> ~/openclaw-workspaces/auto/logs/dashboard-update.log 2>&1
```

## 🔄 更新流程

Mac 上的 `update-local.sh` 會：
1. 收集 OpenClaw 狀態 (`openclaw status`)
2. 更新 `data/status.json`
3. git commit & push
4. GitHub Pages 自動重新部署

## 📱 手機訪問

GitHub Pages 會給你一個**固定網址**：
```
https://YOUR_USERNAME.github.io/openclaw-dashboard
```

**優點：**
- ✅ 完全免費
- ✅ 網址固定不變
- ✅ 自動 HTTPS
- ✅ 全球 CDN（載入速度快）
- ✅ 無需安裝 ngrok

## ⚠️ 注意事項

1. **公開倉庫**：GitHub Pages 需要公開倉庫（或付費 Pro 帳號）
2. **敏感資訊**：確保 `status.json` 不包含敏感資訊（API keys、密碼等）
3. **更新頻率**：GitHub 建議每小時推送不要超過 10 次（我們設 5 分鐘一次是安全的）

## 🛠️ 疑難排解

| 問題 | 解決方案 |
|------|----------|
| Pages 沒有更新 | 檢查倉庫 Settings → Pages 是否顯示 "Your site is published" |
| 資料沒有更新 | 檢查 `update-local.sh` 是否有執行權限，cron log 是否有錯誤 |
| 手機顯示舊資料 | GitHub Pages 有快取，可能需要強制重新整理 (Cmd+Shift+R) |

---

**完成設定後，你就可以在任何地方用手機查看即時狀態了！** 🎉
