import 'dart:io';

class FileData {
  final String name;
  final FileType type;
  final File? file;

  FileData(this.name, this.type, {this.file});
}

enum FileType {
  image,
  video,
  document,
}

class Message {
  final String text;
  final String sender;
  final bool me;
  final bool isFile;
  final FileData? file;

  Message(this.text, this.sender, this.me, this.isFile, this.file);
}
