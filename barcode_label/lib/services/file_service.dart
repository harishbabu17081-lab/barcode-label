import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:path_provider/path_provider.dart'; // Not strictly needed for file_picker save in some cases but good to have
import '../models/canvas_model.dart';
import '../models/widget_model.dart';

class FileService {
  static Future<void> saveTemplate(LabelTemplate template) async {
    final jsonString = jsonEncode(template.toJson());

    if (kIsWeb) {
      // Web specific save logic (download) - simplified or placeholder
      // For now, print to console or use universal_html if strict web support needed
      print('Saving JSON content: $jsonString');
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Template',
        fileName: '${template.templateName}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
      }
    }
  }

  static Future<LabelTemplate?> loadTemplate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String content;
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          content = utf8.decode(bytes);
        } else {
          return null;
        }
      } else {
        final file = File(result.files.single.path!);
        content = await file.readAsString();
      }

      try {
        final jsonMap = jsonDecode(content);
        return LabelTemplate.fromJson(jsonMap);
      } catch (e) {
        print('Error parsing JSON: $e');
        return null; // Return null or throw
      }
    }
    return null;
  }
}
