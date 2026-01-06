import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widget_palette.dart';
import '../widgets/canvas_area.dart';
import '../widgets/properties_panel.dart';
import '../services/file_service.dart';
import '../providers/canvas_provider.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Label Designer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Template',
            onPressed: () {
              final template = context.read<CanvasProvider>().template;
              FileService.saveTemplate(template);
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Template',
            onPressed: () async {
              final template = await FileService.loadTemplate();
              if (template != null && context.mounted) {
                context.read<CanvasProvider>().loadTemplate(template);
              }
            },
          ),
        ],
      ),
      body: Row(
        children: const [
          Expanded(flex: 2, child: WidgetPalette()),
          Expanded(flex: 6, child: CanvasArea()),
          Expanded(flex: 2, child: PropertiesPanel()),
        ],
      ),
    );
  }
}
