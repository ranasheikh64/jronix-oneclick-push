# Jronix AI Push CLI

An automated, AI-powered Git commit and push CLI tool built with Dart. It automatically analyzes your staged and unstaged changes, generates a professional conventional commit message using Google's Gemini AI, and pushes your code to the current branch.

## 🚀 Features

- **Zero Configuration Setup**: Works natively on Windows, Mac, and Linux.
- **Smart Commits**: Uses `git diff` to understand your changes.
- **Conventional Commits**: Automatically uses `feat`, `fix`, `refactor`, `style`, etc.
- **Auto Push**: Stages all files, commits, and pushes to origin automatically.
- **Simple Setup**: One command to initialize, one command to push.

## 🛠️ Installation

You can install this CLI directly from GitHub globally on your machine. Run the following command in your terminal:

```bash
dart pub global activate --source git https://github.com/YOUR_GITHUB_USERNAME/jronix_cli.git
```
*(Make sure to replace `YOUR_GITHUB_USERNAME` with your actual GitHub username)*

Once installed, the `push` command will be globally available on your system!

## 📚 How to Use

### Step 1: Initialize a Project

Go to any of your Git projects and run:
```bash
push init
```
This will create a `.ai_push/config.json` folder inside your project. It contains the API Key and Author details.

### Step 2: Push Your Code!

Whenever you finish working and want to push your code to GitHub, simply type:
```bash
push
```

That's it! The CLI will:
1. `git add .` (Stage all your changes)
2. `git diff` (Analyze what changed)
3. Generate a beautiful, professional commit message
4. `git commit -m "..."`
5. `git push origin <current-branch>`

## ⚙️ Configuration File (`.ai_push/config.json`)

If you want to change your name or API key, edit the `.ai_push/config.json` file generated in your project root:

```json
{
  "provider": "gemini",
  "model": "gemini-1.5-pro",
  "api_key": "YOUR_API_KEY_HERE",
  "author": "Your Name"
}
```
# jronix-oneclick-push
