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
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Label Designer'),
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
            icon: const Icon(Icons.save),
            tooltip: 'Save Local',
            onPressed: () async {
              await context.read<CanvasProvider>().saveTemplateLocal();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template saved locally')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Local',
            onPressed: () async {
              // Simple dialog to load for now
              _showLoadDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to File',
            onPressed: () {
              final template = context.read<CanvasProvider>().template;
              FileService.saveTemplate(template);
            },
          ),
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      drawer: null, // Removed widget drawer for mobile
      endDrawer: isMobile ? const Drawer(child: PropertiesPanel()) : null,
      body: Row(
        children: [
          // On mobile, show compact palette. On desktop, show full palette.
          isMobile
              ? const WidgetPalette(isCompact: true)
              : const Expanded(flex: 2, child: WidgetPalette()),

          isMobile
              ? const Expanded(child: CanvasArea())
              : const Expanded(flex: 6, child: CanvasArea()),

          if (!isMobile) const Expanded(flex: 2, child: PropertiesPanel()),
        ],
      ),
    );
  }

  void _showLoadDialog(BuildContext context) async {
    final provider = context.read<CanvasProvider>();
    var savedNames = await provider.getSavedTemplateNames();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Load Template'),
              content: SizedBox(
                width: double.maxFinite,
                child: savedNames.isEmpty
                    ? const Center(child: Text('No saved templates found.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: savedNames.length,
                        itemBuilder: (context, index) {
                          final name = savedNames[index];
                          return ListTile(
                            title: Text(name),
                            onTap: () async {
                              await provider.loadTemplateLocal(name);
                              if (context.mounted) Navigator.pop(context);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: Text(
                                      'Are you sure you want to delete "$name"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await provider.deleteTemplateLocal(name);
                                  final newNames = await provider
                                      .getSavedTemplateNames();
                                  setState(() {
                                    savedNames = newNames;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
