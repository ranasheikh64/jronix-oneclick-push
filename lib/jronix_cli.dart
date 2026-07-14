import 'dart:convert';
import 'dart:io';

const String configDirName = '.ai_push';
const String configFileName = 'config.json';

void printUsage() {
  print('🌟 Welcome to AI Push (Built by Jronix) 🌟');
  print('Usage:');
  print('  push init   - Initialize the configuration');
  print('  push        - Generate commit message and push');
}

Future<void> initConfig() async {
  final dir = Directory(configDirName);
  if (!await dir.exists()) {
    await dir.create();
  }

  final configFile = File('${dir.path}/$configFileName');
  
  final config = {
    "provider": "gemini",
    "model": "gemini-1.5-pro",
    "api_key": "AIzaSyA1yNb-DKXY6P-BOGtN4o0foCni7jApOrU",
    "author": "Rana Sheikh"
  };

  print('🌟 Welcome to AI Push (Built by Jronix) 🌟');
  await configFile.writeAsString(jsonEncode(config));
  print('✅ Initialization complete. Config saved at ${configFile.path}');
  print('💡 You can now simply run "push" to commit and push your code!');
}

Future<Map<String, dynamic>?> loadConfig() async {
  final configFile = File('$configDirName/$configFileName');
  if (!await configFile.exists()) {
    print('❌ Config not found. Please run "push init" first.');
    return null;
  }
  
  final content = await configFile.readAsString();
  return jsonDecode(content) as Map<String, dynamic>;
}

Future<void> performPush() async {
  final config = await loadConfig();
  if (config == null) return;

  print('🔍 Checking git status...');
  
  // Get current branch
  final branchResult = await Process.run('git', ['branch', '--show-current']);
  if (branchResult.exitCode != 0) {
    print('❌ Failed to get current branch. Is this a git repository?');
    return;
  }
  final currentBranch = branchResult.stdout.toString().trim();
  print('📂 Current branch: $currentBranch');

  // Add all changes first so they are staged
  await Process.run('git', ['add', '.']);

  // Get diff of staged changes
  final diffResult = await Process.run('git', ['diff', '--cached']);
  final diff = diffResult.stdout.toString().trim();

  if (diff.isEmpty) {
    print('⚠️ No changes detected.');
    return;
  }

  print('🧠 Analyzing changed files and generating commit message...');
  
  final commitMessage = await generateCommitMessage(diff, config);
  
  if (commitMessage == null || commitMessage.isEmpty) {
    print('❌ Failed to generate commit message.');
    return;
  }
  
  final date = DateTime.now().toString().split('.').first;
  final author = config['author'] ?? 'Jronix User';
  
  final formattedCommitMessage = '''$commitMessage

Generated-By: AI Push (Built by Jronix)
Author: $author
Date: $date''';

  print('\n📝 Generated Commit Message:');
  print('-----------------------------------------');
  print(formattedCommitMessage);
  print('-----------------------------------------');
  
  print('🚀 Committing...');
  final commitResult = await Process.run('git', ['commit', '-m', formattedCommitMessage]);
  if (commitResult.exitCode != 0) {
    print('❌ Commit failed:\n${commitResult.stderr}');
    return;
  }
  
  print('☁️ Pushing to origin $currentBranch...');
  final pushResult = await Process.run('git', ['push', 'origin', currentBranch]);
  if (pushResult.exitCode != 0) {
    print('❌ Push failed:\n${pushResult.stderr}');
    return;
  }
  
  print('✅ Successfully pushed to $currentBranch! (Built by Jronix) 🌟');
}

Future<String?> generateCommitMessage(String diff, Map<String, dynamic> config) async {
  final apiKey = config['api_key'];
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

  final prompt = '''
You are a senior software engineer.
Generate a conventional commit message based on the following git diff.

Rules:
- max 70 chars for the title
- lowercase title
- no emoji
- use feat/fix/refactor/chore/docs/test/style/perf
- professional
- Return ONLY the commit message text. Do not use markdown blocks or quotes.

Git diff:
$diff
''';

  final requestBody = {
    "contents": [
      {
        "parts": [
          {"text": prompt}
        ]
      }
    ],
    "generationConfig": {
      "temperature": 0.2
    }
  };

  try {
    final httpClient = HttpClient();
    final request = await httpClient.postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(requestBody));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      final text = json['candidates'][0]['content']['parts'][0]['text'];
      return text.toString().trim();
    } else {
      print('API Error: \${response.statusCode} - \$responseBody');
      return null;
    }
  } catch (e) {
    print('Error calling API: \$e');
    return null;
  }
}
