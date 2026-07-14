import 'package:jronix_cli/jronix_cli.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty && arguments[0] == 'init') {
    await initConfig();
  } else if (arguments.isNotEmpty && arguments[0] == '--help') {
    printUsage();
  } else {
    await performPush();
  }
}
