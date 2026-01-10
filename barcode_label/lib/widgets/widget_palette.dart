import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/widget_model.dart';
import '../providers/canvas_provider.dart';

class WidgetPalette extends StatelessWidget {
  final bool isCompact;

  const WidgetPalette({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 56 : 250, // Fixed width for compact/full
      color: Colors.grey[200],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isCompact
                ? const Icon(Icons.widgets, size: 20)
                : const Text(
                    'Widgets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDraggableItem(
                  context,
                  'Text',
                  Icons.text_fields,
                  WidgetType.text,
                ),
                _buildDraggableItem(
                  context,
                  'Barcode',
                  Icons.qr_code,
                  WidgetType.barcode,
                ),
                _buildDraggableItem(
                  context,
                  'Shape',
                  Icons.shape_line,
                  WidgetType.shape,
                ),
                _buildDraggableItem(
                  context,
                  'Image',
                  Icons.image,
                  WidgetType.image,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(
    BuildContext context,
    String label,
    IconData icon,
    WidgetType type,
  ) {
    final itemContent = isCompact
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: Icon(icon, color: Colors.blueGrey)),
          )
        : ListTile(leading: Icon(icon), title: Text(label));

    return Draggable<WidgetType>(
      key: ValueKey(
        '${type}_${DateTime.now().millisecondsSinceEpoch}',
      ),  
      data: type,
      feedback: Material(
        color: Colors.transparent, 
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon), const SizedBox(width: 8), Text(label)],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: itemContent),
      onDragEnd: (details) {
        // Optional cleanup if needed
      },
      child: InkWell(
        onTap: () {
          final provider = Provider.of<CanvasProvider>(context, listen: false);
          _addWidgetToCenter(provider, type);
        },
        child: itemContent,
      ),
    );
  }

  void _addWidgetToCenter(CanvasProvider provider, WidgetType type) {
    double defaultW = 100;
    double defaultH = 50;
    Map<String, dynamic> initialProps = {};

    switch (type) {
      case WidgetType.text:
        initialProps = {
          'content': 'New Text',
          'fontSize': 20.0,
          'fontFamily': 'Roboto',
          'color': 0xFF000000,
        };
        defaultW = 120;
        defaultH = 40;
        break;
      case WidgetType.barcode:
        initialProps = {'data': '12345678', 'barcodeType': 'Code128'};
        defaultW = 200;
        defaultH = 100;
        break;
      case WidgetType.shape:
        initialProps = {
          'shapeType': 'rectangle',
          'strokeWidth': 2.0,
          'strokeColor': '#000000',
        };
        defaultW = 100;
        defaultH = 100;
        break;
      default:
        break;
    }

    // Finalize centering logic
    // Center of 800x600 canvas assumption or arbitrary for now
    double centerX = 50;
    double centerY = 50;

    provider.addWidget(
      LabelWidget(
        type: type,
        position: WidgetPosition(
          x: centerX,
          y: centerY,
          width: defaultW,
          height: defaultH,
        ),
        properties: initialProps,
      ),
    );
  }
}
