import 'package:flutter/material.dart';
import '../models/canvas_model.dart';
import '../models/widget_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CanvasProvider extends ChangeNotifier {
  LabelTemplate _template;
  String? _selectedWidgetId;
  String _activePageId = 'page_1'; 

  CanvasProvider()
    : _template = LabelTemplate(
        templateName: 'New Template',
        canvasProperties: CanvasProperties(),
        pages: [LabelPage(id: 'page_1', widgets: [])],
      );

  LabelTemplate get template => _template;
  String? get selectedWidgetId => _selectedWidgetId;

  LabelWidget? get selectedWidget {
    if (_selectedWidgetId == null) return null;
    for (var page in _template.pages) {
      try {
        return page.widgets.firstWhere((w) => w.id == _selectedWidgetId);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  String get activePageId => _activePageId;

  void setActivePage(String pageId) {
    if (_activePageId != pageId) {
      _activePageId = pageId;
      notifyListeners();
    }
  }

  final List<LabelTemplate> _undoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;

  void _saveState() {
    final json = _template.toJson();
    final copy = LabelTemplate.fromJson(json);
    _undoStack.add(copy);
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _template = _undoStack.removeLast();
      _selectedWidgetId = null;
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
    final pageIndex = _template.pages.indexWhere((p) => p.id == _activePageId);
    if (pageIndex != -1) {
      _template.pages[pageIndex].widgets.add(widget);
      _selectedWidgetId = widget.id;
      notifyListeners();
    }
  }

  void removeWidget(String id) {
    _saveState();
    for (var page in _template.pages) {
      page.widgets.removeWhere((w) => w.id == id);
    }
    if (_selectedWidgetId == id) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  void addPage() {
    _saveState();
    final newPageId =
        'page_${_template.pages.length + 1}_${DateTime.now().millisecondsSinceEpoch}';
    _template.pages.add(LabelPage(id: newPageId, widgets: []));
    _activePageId = newPageId;
    notifyListeners();
  }

  void removePage(String pageId) {
    if (_template.pages.length <= 1) return;
    _saveState();
    _template.pages.removeWhere((p) => p.id == pageId);
    if (_activePageId == pageId) {
      _activePageId = _template.pages.first.id;
    }
    notifyListeners();
  }

  void selectWidget(String? id) {
    _selectedWidgetId = id;
    notifyListeners();
  }

  void updateWidgetPosition(String id, WidgetPosition position) {
    for (var page in _template.pages) {
      final index = page.widgets.indexWhere((w) => w.id == id);
      if (index != -1) {
        page.widgets[index].position = position;
        notifyListeners();
        return;
      }
    }
  }
  void prepareUndo() {
    _saveState();
  }

  void updateWidgetProperties(String id, Map<String, dynamic> properties) {
    _saveState();
    for (var page in _template.pages) {
      final index = page.widgets.indexWhere((w) => w.id == id);
      if (index != -1) {
        page.widgets[index].properties = Map<String, dynamic>.from(properties);
        notifyListeners();
        return;
      }
    }
  }

  void loadTemplate(LabelTemplate template) {
    _undoStack.clear(); 
    _template = template;
    _selectedWidgetId = null;
    if (_template.pages.isNotEmpty) {
      _activePageId = _template.pages.first.id;
    }
    notifyListeners();
  }

  void updateWidget(String id, LabelWidget updatedWidget) {
    _saveState();
    for (var page in _template.pages) {
      final index = page.widgets.indexWhere((w) => w.id == id);
      if (index != -1) {
        page.widgets[index] = updatedWidget;
        notifyListeners();
        return;
      }
    }
  }

  void createNewTemplate() {
    _saveState(); 
    _template = LabelTemplate(
      templateName: 'New Template',
      canvasProperties: CanvasProperties(),
      pages: [LabelPage(id: 'page_1', widgets: [])],
    );
    _selectedWidgetId = null;
    _activePageId = 'page_1';
    notifyListeners();
  }

  void renameTemplate(String newName) {
    
    _template.templateName = newName;
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
