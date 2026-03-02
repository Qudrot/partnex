import 'dart:io';

void main() async {
  final content = File('out.json').readAsStringSync();
  print(content.substring(0, 1000));
}
