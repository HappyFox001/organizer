import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> exportToFile(String data, String filename) async {
    try {
      final file = await _localFile(filename);
      await file.writeAsString(data);
      await Share.shareFiles(
        [file.path],
        text: 'Task Manager Backup',
      );
    } catch (e) {
      throw Exception('Could not export file: $e');
    }
  }

  Future<String?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      throw Exception('Could not import file: $e');
    }
  }

  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject,
    );
  }
}
