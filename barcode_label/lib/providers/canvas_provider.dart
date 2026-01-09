import 'package:flutter/material.dart';
import '../models/canvas_model.dart';
import '../models/widget_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  final List<LabelTemplate> _undoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;

  void _saveState() {
    // Deep copy via JSON
    final json = _template.toJson();
    final copy = LabelTemplate.fromJson(json);
    _undoStack.add(copy);

    // Limit stack size if needed, e.g. 20
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _template = _undoStack.removeLast();
      _selectedWidgetId = null; // Deselect to avoid consistency issues
      notifyListeners();
    }
  }

  void updateCanvasProperties(CanvasProperties props) {
    _saveState();
    _template.canvasProperties = props;
    notifyListeners();
  }

  void addWidget(LabelWidget widget) {
    _saveState();
    _template.widgets.add(widget);
    _selectedWidgetId = widget.id;
    notifyListeners();
  }

  void removeWidget(String id) {
    _saveState();
    _template.widgets.removeWhere((w) => w.id == id);
    if (_selectedWidgetId == id) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  void selectWidget(String? id) {
    // Selection doesn't need undo state usually, but user preference may vary.
    // Generally navigation is not undoable.
    _selectedWidgetId = id;
    notifyListeners();
  }

  void updateWidgetPosition(String id, WidgetPosition position) {
    // For performance, we might want to debounce this or save state only on panEnd.
    // But provider doesn't know about panEnd.
    // CanvasArea calls this continuously.
    // TODO: Calling saveState on every pixel move is bad.
    // We need a separate method for "finish move" or handle snapshotting differently.

    // For now, let's NOT save state on every updateWidgetPosition call if it's continuous.
    // However, without it, undo will be broken for moves.
    // Better strategy: The UI (CanvasArea) should call 'saveState' before starting a drag.
    // But we want to encapsulate logic here.

    // Let's rely on a separate method 'startTransaction' or similar, OR
    // check if we are already in a "drag" state.

    // Simplest fix for "revert option" request: Just save state on property changes and adds/removes.
    // For moves, we might spam the stack.
    // Let's implement 'saveState' but maybe we only call it if the position changed significantly?
    // No, drag interactions must simply call `saveState` ONCE at start.
    // But we don't have that hook easily exposed to Provider from existing specific update methods without refactoring `CanvasArea`.

    // Let's modify logic: assume `CanvasArea` will handle the "snapshot before drag".
    // OR, providing a `prepareForChange()` method.

    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      // We won't call _saveState() here automatically to avoid flood.
      // The UI calling this should call prepareUndo() before starting modification.
      _template.widgets[index].position = position;
      notifyListeners();
    }
  }

  // Helper for UI to call before continuous ops
  void prepareUndo() {
    _saveState();
  }

  void updateWidgetProperties(String id, Map<String, dynamic> properties) {
    _saveState();
    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _template.widgets[index].properties = Map<String, dynamic>.from(
        properties,
      );
      notifyListeners();
    }
  }

  void loadTemplate(LabelTemplate template) {
    _undoStack.clear(); // Clear stack on new load
    _template = template;
    _selectedWidgetId = null;
    notifyListeners();
  }

  void updateWidget(String id, LabelWidget updatedWidget) {
    _saveState();
    final index = _template.widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _template.widgets[index] = updatedWidget;
      notifyListeners();
    }
  }

  void createNewTemplate() {
    _saveState(); // Save old one just in case
    _template = LabelTemplate(
      templateName: 'New Template',
      canvasProperties: CanvasProperties(),
      widgets: [],
    );
    _selectedWidgetId = null;
    notifyListeners();
  }

  Future<void> saveTemplateLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String currentJson = jsonEncode(_template.toJson());
    await prefs.setString('template_${_template.templateName}', currentJson);

    List<String> templateNames = prefs.getStringList('template_names') ?? [];
    if (!templateNames.contains(_template.templateName)) {
      templateNames.add(_template.templateName);
      await prefs.setStringList('template_names', templateNames);
    }
  }

  Future<LabelTemplate?> loadTemplateLocal(String templateName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('template_$templateName');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        final template = LabelTemplate.fromJson(jsonMap);
        loadTemplate(template);
        return template;
      } catch (e) {
        print('Error loading template: $e');
        return null;
      }
    }
    return null;
  }

  Future<List<String>> getSavedTemplateNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('template_names') ?? [];
  }

  Future<void> deleteTemplateLocal(String templateName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('template_$templateName');

    List<String> templateNames = prefs.getStringList('template_names') ?? [];
    if (templateNames.contains(templateName)) {
      templateNames.remove(templateName);
      await prefs.setStringList('template_names', templateNames);
    }
  }
}
