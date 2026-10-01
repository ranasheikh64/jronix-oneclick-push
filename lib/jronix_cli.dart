import 'dart:convert';
import 'dart:io';

const String configFileName = '.env';

void printUsage() {
  print('🌟 Welcome to AI Push (Built by Jronix) 🌟');
  print('Usage:');
  print('  push init   - Initialize the configuration');
  print('  push        - Generate commit message and push');
}

String _updateOrAppendEnv(String content, String key, String value) {
  final regExp = RegExp('^$key=.*', multiLine: true);
  if (regExp.hasMatch(content)) {
    return content.replaceAll(regExp, '$key=$value');
  } else {
    return content + (content.isEmpty || content.endsWith('\n') ? '' : '\n') + '$key=$value\n';
  }
}

Future<void> initConfig() async {
  stdout.write('Enter your API Key (Gemini or OpenAI auto-detected): ');
  final apiKey = stdin.readLineSync()?.trim() ?? '';

  String apiType = 'gemini';
  if (apiKey.startsWith('sk-')) {
    apiType = 'openai';
    print('🤖 Auto-detected OpenAI API Key.');
  } else if (apiKey.startsWith('AIza')) {
    apiType = 'gemini';
    print('🤖 Auto-detected Gemini API Key.');
  } else {
    print('⚠️ Could not definitively auto-detect API key type. Defaulting to Gemini.');
  }

  stdout.write('Enter your Author Name for commits (e.g. Rana Sheikh): ');
  final author = stdin.readLineSync()?.trim() ?? 'Jronix User';

  final envFile = File(configFileName);
  String envContent = '';
  if (await envFile.exists()) {
    envContent = await envFile.readAsString();
  }

  envContent = _updateOrAppendEnv(envContent, 'AI_PUSH_API_KEY', apiKey);
  envContent = _updateOrAppendEnv(envContent, 'AI_PUSH_API_TYPE', apiType);
  envContent = _updateOrAppendEnv(envContent, 'AI_PUSH_AUTHOR', author);
  
  if (apiType == 'gemini') {
    envContent = _updateOrAppendEnv(envContent, 'AI_PUSH_MODEL', 'gemini-1.5-flash');
  } else {
    envContent = _updateOrAppendEnv(envContent, 'AI_PUSH_MODEL', 'gpt-4o-mini');
  }

  await envFile.writeAsString(envContent);

  final gitignore = File('.gitignore');
  if (await gitignore.exists()) {
    final content = await gitignore.readAsString();
    if (!content.contains('.env')) {
      await gitignore.writeAsString('\n.env\n', mode: FileMode.append);
    }
  } else {
    await gitignore.writeAsString('.env\n');
  }

  print('🌟 Welcome to AI Push (Built by Jronix) 🌟');
  print('✅ Initialization complete. Config saved at .env and added to .gitignore');
  print('💡 You can now simply run "push" to commit and push your code!');
}

Future<Map<String, dynamic>?> loadConfig() async {
  final envFile = File(configFileName);
  if (!await envFile.exists()) {
    print('❌ .env not found. Please run "push init" first.');
    return null;
  }
  
  final lines = await envFile.readAsLines();
  final config = <String, dynamic>{
    'api_type': 'gemini', // default
  };
  for (var line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      if (key == 'AI_PUSH_API_KEY' || key == 'GEMINI_API_KEY') config['api_key'] = value;
      if (key == 'AI_PUSH_AUTHOR' || key == 'AUTHOR') config['author'] = value;
      if (key == 'AI_PUSH_MODEL' || key == 'MODEL') config['model'] = value;
      if (key == 'AI_PUSH_API_TYPE') config['api_type'] = value;
    }
  }
  return config;
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

  final spinner = Spinner('🧠 Analyzing changed files and generating commit message...');
  spinner.start();
  
  String? commitMessage = await generateCommitMessage(diff, config);
  
  spinner.stop();
  
  if (commitMessage == null || commitMessage.isEmpty) {
    print('⚠️ AI failed to generate commit message.');
    stdout.write('Please enter your commit message manually: ');
    commitMessage = stdin.readLineSync()?.trim();
    if (commitMessage == null || commitMessage.isEmpty) {
      print('❌ Commit cancelled.');
      return;
    }
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
  final apiType = config['api_type'] ?? 'gemini';
  final model = config['model'] ?? (apiType == 'openai' ? 'gpt-4o-mini' : 'gemini-1.5-flash');

  final prompt = '''
You are an expert senior software engineer.
Generate a highly descriptive, conventional commit message based on the following git diff.

Rules:
1. The first line must be a short, clear commit title (max 70 characters), starting with a type (feat, fix, refactor, chore, docs, test, style, perf) in lowercase. Do NOT use emojis.
2. Leave one blank line after the title.
3. Provide a concise bulleted list explaining the key changes in the body if the diff is complex enough.
4. Focus on the "why" and "what" rather than the exact code changes.
5. Professional tone.
6. Return ONLY the final commit message text without any markdown wrappers (like ```).

Git diff:
$diff
''';

  if (apiType == 'openai') {
    return _generateWithOpenAI(prompt, apiKey, model);
  } else {
    return _generateWithGemini(prompt, apiKey, model);
  }
}

Future<String?> _generateWithOpenAI(String prompt, String apiKey, String model) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final requestBody = {
    "model": model,
    "messages": [
      {"role": "user", "content": prompt}
    ],
    "temperature": 0.2
  };

  try {
    final httpClient = HttpClient();
    final request = await httpClient.postUrl(url);
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Authorization', 'Bearer $apiKey');
    
    final requestBodyString = jsonEncode(requestBody);
    request.add(utf8.encode(requestBodyString));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      final text = json['choices'][0]['message']['content'];
      return text.toString().trim().replaceAll(RegExp(r'^```[\s\S]*?\n|```$'), '');
    } else {
      print('OpenAI API Error: ${response.statusCode} - $responseBody');
      return null;
    }
  } catch (e) {
    print('Error calling OpenAI API: $e');
    return null;
  }
}

Future<String?> _generateWithGemini(String prompt, String apiKey, String model) async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
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
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    
    final requestBodyString = jsonEncode(requestBody);
    request.add(utf8.encode(requestBodyString));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      final text = json['candidates'][0]['content']['parts'][0]['text'];
      return text.toString().trim().replaceAll(RegExp(r'^```[\s\S]*?\n|```$'), '');
    } else {
      print('API Error: ${response.statusCode} - $responseBody');
      return null;
    }
  } catch (e) {
    print('Error calling API: $e');
    return null;
  }
}

class Spinner {
  bool _isSpinning = false;
  final List<String> _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int _index = 0;
  final String message;

  Spinner(this.message);

  void start() {
    _isSpinning = true;
    _spin();
  }

  void stop() {
    _isSpinning = false;
    stdout.write('\r\x1B[K'); // clear line
  }

  void _spin() async {
    while (_isSpinning) {
      stdout.write('\r${_frames[_index]} $message');
      _index = (_index + 1) % _frames.length;
      await Future.delayed(Duration(milliseconds: 80));
    }
  }
}
