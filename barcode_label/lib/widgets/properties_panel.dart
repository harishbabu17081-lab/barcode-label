import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canvas_provider.dart';
import '../models/widget_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Properties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: Consumer<CanvasProvider>(
              builder: (context, provider, child) {
                final widget = provider.selectedWidget;
                if (widget == null) {
                  return const Center(
                    child: Text('Select a widget to edit properties'),
                  );
                }
                return _buildPropertiesForm(context, widget, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesForm(
    BuildContext context,
    LabelWidget widget,
    CanvasProvider provider,
  ) {
    return ListView(
      children: [
        _buildSectionHeader('Position & Size'),
        _buildNumberField('X', widget.position.x, (val) {
          provider.updateWidgetPosition(
            widget.id,
            _updatePos(widget.position, x: val),
          );
        }),
        _buildNumberField('Y', widget.position.y, (val) {
          provider.updateWidgetPosition(
            widget.id,
            _updatePos(widget.position, y: val),
          );
        }),
        _buildNumberField('Width', widget.position.width, (val) {
          provider.updateWidgetPosition(
            widget.id,
            _updatePos(widget.position, width: val),
          );
        }),
        _buildNumberField('Height', widget.position.height, (val) {
          provider.updateWidgetPosition(
            widget.id,
            _updatePos(widget.position, height: val),
          );
        }),
        const SizedBox(height: 16),
        _buildSectionHeader('Widget Properties'),
        if (widget.type == WidgetType.text) ...[
          _buildTextField('Content', widget.properties['content'] ?? '', (val) {
            _updateProp(provider, widget, 'content', val);
          }),
          _buildNumberField(
            'Font Size',
            (widget.properties['fontSize'] as num?)?.toDouble() ?? 14,
            (val) {
              _updateProp(provider, widget, 'fontSize', val);
            },
          ),
          _buildColorPickerField(
            context,
            'Color',
            Color(widget.properties['color'] ?? 0xFF000000),
            (color) {
              _updateProp(provider, widget, 'color', color.value);
            },
          ),
        ] else if (widget.type == WidgetType.barcode) ...[
          _buildTextField('Data', widget.properties['data'] ?? '', (val) {
            _updateProp(provider, widget, 'data', val);
          }),
        ] else if (widget.type == WidgetType.image) ...[
          // Image Picker
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Image Source'),
                const SizedBox(height: 8),
                if (widget.properties['path'] != null)
                  Text(
                    'Selected: ...${widget.properties['path'].toString().split(r'\').last}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                  onPressed: () async {
                    // Import file_picker at top
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      _updateProp(
                        provider,
                        widget,
                        'path',
                        result.files.single.path,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  WidgetPosition _updatePos(
    WidgetPosition pos, {
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return WidgetPosition(
      x: x ?? pos.x,
      y: y ?? pos.y,
      width: width ?? pos.width,
      height: height ?? pos.height,
      rotation: pos.rotation,
    );
  }

  void _updateProp(
    CanvasProvider provider,
    LabelWidget widget,
    String key,
    dynamic value,
  ) {
    final newProps = Map<String, dynamic>.from(widget.properties);
    newProps[key] = value;
    provider.updateWidgetProperties(widget.id, newProps);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label)),
          Expanded(
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final numVal = double.tryParse(val);
                if (numVal != null) onChanged(numVal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerField(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: onColorChanged,
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Got it'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
