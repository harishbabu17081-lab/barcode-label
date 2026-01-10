import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widget_palette.dart';
import '../widgets/canvas_area.dart';
import '../widgets/properties_panel.dart';
import '../services/file_service.dart';
import '../providers/canvas_provider.dart';
import '../widgets/save_template_dialog.dart';
import '../widgets/load_template_dialog.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Label Designer'),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          // Undo Button
          Consumer<CanvasProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: provider.canUndo ? () => provider.undo() : null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'New Sheet',
            onPressed: () {
              context.read<CanvasProvider>().createNewTemplate();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Page',
            onPressed: () {
              context.read<CanvasProvider>().addPage();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('New page added')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Local',
            onPressed: () {
              final provider = context.read<CanvasProvider>();
              showDialog(
                context: context,
                builder: (context) => SaveTemplateDialog(
                  initialName: provider.template.templateName,
                  onSave: (newName) async {
                    provider.renameTemplate(newName);
                    await provider.saveTemplateLocal();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Template "$newName" saved locally'),
                          behavior: SnackBarBehavior.floating,
                          // width: 400, // Removed fixed width for responsiveness
                          margin: const EdgeInsets.all(
                            16,
                          ), // Added margin for better mobile look
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Local',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LoadTemplateDialog(),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   tooltip: 'Export to File',
          //   onPressed: () {
          //     final template = context.read<CanvasProvider>().template;
          //     FileService.saveTemplate(template);
          //   },
          // ),
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      drawer: null,
      endDrawer: isMobile ? const Drawer(child: PropertiesPanel()) : null,
      body: Row(
        children: [
          isMobile
              ? const WidgetPalette(isCompact: true)
              : const SizedBox(width: 250, child: WidgetPalette()),

          const Expanded(child: CanvasArea()),

          if (!isMobile) const SizedBox(width: 300, child: PropertiesPanel()),
        ],
      ),
    );
  }
}
