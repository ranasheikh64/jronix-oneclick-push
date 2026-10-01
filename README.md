# Jronix AI Push CLI

An automated, AI-powered Git commit and push CLI tool built with Dart. It automatically analyzes your staged and unstaged changes, generates a professional conventional commit message using **OpenAI** or Google's **Gemini AI**, and pushes your code to the current branch.

## 🚀 Features

- **Zero Configuration Setup**: Works natively on Windows, Mac, and Linux.
- **Smart Commits**: Uses `git diff` to understand your changes.
- **Conventional Commits**: Automatically uses `feat`, `fix`, `refactor`, `style`, etc.
- **Auto Push**: Stages all files, commits, and pushes to origin automatically.
- **Auto-Detect API**: Simply paste your OpenAI (`sk-`) or Gemini (`AIza`) key and it will auto-configure itself.
- **Safe Environment**: Appends configuration to your `.env` without overwriting your existing variables.

## 🛠️ Installation

You can install this CLI directly from GitHub globally on your machine. Run the following command in your terminal:

```bash
dart pub global activate --source git https://github.com/ranasheikh64/jronix-oneclick-push.git
```

Once installed, the `push` command will be globally available on your system!

## 📚 How to Use

### Step 1: Initialize a Project

Go to any of your Git projects and run:
```bash
push init
```
This will safely append the AI Push configuration to your `.env` file (and add it to `.gitignore` if it's not already there). It will ask for your API key and Author name. It will automatically detect if you are using OpenAI or Gemini based on your key format.

### Step 2: Push Your Code!

Whenever you finish working and want to push your code to GitHub, simply type:
```bash
push
```

That's it! The CLI will:
1. `git add .` (Stage all your changes)
2. `git diff` (Analyze what changed)
3. Generate a beautiful, professional commit message using OpenAI/Gemini
4. `git commit -m "..."`
5. `git push origin <current-branch>`

## ⚙️ Configuration (`.env`)

The CLI securely saves its configuration into your project's `.env` file using the `AI_PUSH_` prefix so it won't conflict with your app's variables. If you need to update it manually, look for these variables:

```env
AI_PUSH_API_KEY=your_api_key_here
AI_PUSH_API_TYPE=openai_or_gemini
AI_PUSH_AUTHOR=Your Name
AI_PUSH_MODEL=gpt-4o-mini
```
