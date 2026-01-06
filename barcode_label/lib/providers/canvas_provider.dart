import 'package:flutter/material.dart';
import '../models/canvas_model.dart';
import '../models/widget_model.dart';

class CanvasProvider extends ChangeNotifier {
  LabelTemplate _template;
  String? _selectedWidgetId;

  CanvasProvider()
    : _template = LabelTemplate(
        templateName: 'New Template',
        canvasProperties: CanvasProperties(),
        widgets: [],
      );

  LabelTemplate get template => _template;
  String? get selectedWidgetId => _selectedWidgetId;

  LabelWidget? get selectedWidget {
    if (_selectedWidgetId == null) return null;
    try {
      return _template.widgets.firstWhere((w) => w.id == _selectedWidgetId);
    } catch (e) {
      return null;
    }
  }

  void updateCanvasProperties(CanvasProperties props) {
    _template.canvasProperties = props;
    notifyListeners();
  }

  void addWidget(LabelWidget widget) {
    _template.widgets.add(widget);
    _selectedWidgetId = widget.id;
    notifyListeners();
  }

  void removeWidget(String id) {
    _template.widgets.removeWhere((w) => w.id == id);
    if (_selectedWidgetId == id) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  void selectWidget(String? id) {
    _selectedWidgetId = id;
    notifyListeners();
  }

  void updateWidgetPosition(String id, WidgetPosition position) {
    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _template.widgets[index].position = position;
      notifyListeners();
    }
  }

  void updateWidgetProperties(String id, Map<String, dynamic> properties) {
    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      // Create new map to ensure change detection if check equality (though properties is map)
      _template.widgets[index].properties = Map<String, dynamic>.from(
        properties,
      );
      notifyListeners();
    }
  }

  void loadTemplate(LabelTemplate template) {
    _template = template;
    _selectedWidgetId = null;
    notifyListeners();
  }

  void updateWidget(String id, LabelWidget updatedWidget) {
    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _template.widgets[index] = updatedWidget;
      notifyListeners();
    }
  }
}
