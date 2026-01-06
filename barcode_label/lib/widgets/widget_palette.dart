import 'package:flutter/material.dart';
import '../models/widget_model.dart';

class WidgetPalette extends StatelessWidget {
  const WidgetPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Widgets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDraggableItem('Text', Icons.text_fields, WidgetType.text),
                _buildDraggableItem(
                  'Barcode',
                  Icons.qr_code,
                  WidgetType.barcode,
                ),
                _buildDraggableItem(
                  'Shape',
                  Icons.shape_line,
                  WidgetType.shape,
                ),
                _buildDraggableItem('Image', Icons.image, WidgetType.image),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(String label, IconData icon, WidgetType type) {
    return Draggable<WidgetType>(
      data: type,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(label)],
          ),
        ),
      ),
      child: ListTile(leading: Icon(icon), title: Text(label)),
    );
  }
}
