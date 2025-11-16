# GitHub 代码上传指南

## ✅ 已完成

- ✅ Git 仓库已初始化
- ✅ 远程仓库已添加：https://github.com/PandaXu/hymessage.git
- ✅ 所有文件已添加到暂存区
- ✅ 代码已提交（28 个文件，3185 行代码）

## 🔐 需要身份验证

GitHub 现在要求使用 **Personal Access Token** 或 **SSH** 进行身份验证。

### 方法一：使用 Personal Access Token（推荐）

#### 步骤 1: 创建 Personal Access Token

1. **访问 GitHub 设置**
   - 打开：https://github.com/settings/tokens
   - 或：GitHub → 头像 → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **生成新 Token**
   - 点击 "Generate new token" → "Generate new token (classic)"
   - 输入名称：`HYMessage Project`
   - 选择过期时间：建议选择 "No expiration" 或 90 天
   - 勾选权限：
     - ✅ `repo` (完整仓库访问权限)

3. **生成并复制 Token**
   - 点击 "Generate token"
   - **重要**：立即复制 Token，只显示一次！

#### 步骤 2: 使用 Token 推送

```bash
cd /Users/heytea/HYMessage

# 方法 A: 在 URL 中使用 Token（一次性）
git push https://YOUR_TOKEN@github.com/PandaXu/hymessage.git main

# 方法 B: 配置 Git Credential Helper（推荐）
git config --global credential.helper osxkeychain
git push -u origin main
# 用户名：PandaXu
# 密码：粘贴你的 Token（不是 GitHub 密码）
```

### 方法二：使用 SSH（更安全）

#### 步骤 1: 生成 SSH 密钥

```bash
# 检查是否已有 SSH 密钥
ls -al ~/.ssh

# 如果没有，生成新密钥
ssh-keygen -t ed25519 -C "your_email@example.com"
# 按 Enter 使用默认路径
# 可以设置密码（可选）

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

#### 步骤 2: 添加 SSH 密钥到 GitHub

1. **复制公钥**
   ```bash
   pbcopy < ~/.ssh/id_ed25519.pub
   ```

2. **添加到 GitHub**
   - 访问：https://github.com/settings/keys
   - 点击 "New SSH key"
   - Title: `Mac - HYMessage`
   - Key: 粘贴公钥
   - 点击 "Add SSH key"

#### 步骤 3: 更改远程 URL 为 SSH

```bash
cd /Users/heytea/HYMessage

# 更改远程 URL
git remote set-url origin git@github.com:PandaXu/hymessage.git

# 测试连接
ssh -T git@github.com

# 推送代码
git push -u origin main
```

## 🚀 快速推送命令

### 如果使用 Token：

```bash
cd /Users/heytea/HYMessage

# 配置 credential helper（只需一次）
git config --global credential.helper osxkeychain

# 推送（会提示输入用户名和密码）
git push -u origin main
# 用户名：PandaXu
# 密码：你的 Personal Access Token
```

### 如果使用 SSH：

```bash
cd /Users/heytea/HYMessage

# 更改远程 URL
git remote set-url origin git@github.com:PandaXu/hymessage.git

# 推送
git push -u origin main
```

## 📋 当前状态

```bash
# 查看远程仓库
git remote -v

# 查看提交历史
git log --oneline

# 查看状态
git status
```

## ✅ 推送成功后

推送成功后，你可以：

1. **访问仓库**
   - https://github.com/PandaXu/hymessage

2. **查看代码**
   - 所有文件都会显示在 GitHub 上

3. **后续更新**
   ```bash
   git add .
   git commit -m "更新说明"
   git push
   ```

## 🔧 常见问题

### 问题 1: "Authentication failed"

**解决**：
- 确保使用 Personal Access Token（不是密码）
- 检查 Token 是否过期
- 检查 Token 权限是否包含 `repo`

### 问题 2: "Permission denied (publickey)"

**解决**：
- 使用 SSH 方法
- 确保 SSH 密钥已添加到 GitHub
- 测试连接：`ssh -T git@github.com`

### 问题 3: "Repository not found"

**解决**：
- 确保仓库 URL 正确
- 确保有仓库的访问权限
- 检查仓库是否已创建

## 💡 推荐方案

**推荐使用 SSH**，因为：
- ✅ 更安全
- ✅ 不需要每次输入密码
- ✅ 一次配置，长期使用

---

**下一步**：选择一种身份验证方法，然后推送代码！

