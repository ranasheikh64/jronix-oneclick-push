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

### Step 1: Initialize (Only Once!)

Open your terminal anywhere and run:
```bash
push init
```
This will securely save the configuration **globally on your machine** (in `~/.ai_push_config`). You only need to do this once! It will automatically detect if you are using an OpenAI or Gemini key.

### Step 2: Push Your Code!

Now you can go to **any Git project** on your computer. Whenever you finish working, simply type:
```bash
push
```

That's it! The CLI will:
1. `git add .` (Stage all your changes)
2. `git diff` (Analyze what changed)
3. Generate a beautiful, professional commit message using OpenAI/Gemini
4. `git commit -m "..."`
5. `git push origin <current-branch>`

## ⚙️ Configuration

The CLI securely saves its configuration globally in your user directory (`~/.ai_push_config`). If you need to update it, you can just run `push init` again or edit the file manually. (It also fully supports falling back to a local project `.env` file if you have project-specific keys).
