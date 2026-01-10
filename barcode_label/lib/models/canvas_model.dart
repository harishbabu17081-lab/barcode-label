import 'package:json_annotation/json_annotation.dart';
import 'widget_model.dart';
part 'canvas_model.g.dart';

enum LabelOrientation { portrait, landscape }

enum LabelUnits { mm, inches }

@JsonSerializable()
class CanvasProperties {
  double width;
  double height;
  LabelOrientation orientation;
  LabelUnits units;
  String backgroundColor;

  CanvasProperties({
    this.width = 150,
    this.height = 150,
    this.orientation = LabelOrientation.portrait,
    this.units = LabelUnits.mm,
    this.backgroundColor = '#FFFFFF',
  });

  factory CanvasProperties.fromJson(Map<String, dynamic> json) =>
      _$CanvasPropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$CanvasPropertiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LabelPage {
  String id;
  List<LabelWidget> widgets;

  LabelPage({required this.id, required this.widgets});

  factory LabelPage.fromJson(Map<String, dynamic> json) =>
      _$LabelPageFromJson(json);
  Map<String, dynamic> toJson() => _$LabelPageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LabelTemplate {
  String templateName;
  String version;
  CanvasProperties canvasProperties;
  List<LabelPage> pages;

  LabelTemplate({
    required this.templateName,
    this.version = '1.0',
    required this.canvasProperties,
    required this.pages,
  });

  factory LabelTemplate.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('widgets') && !json.containsKey('pages')) {
      final widgetsList = (json['widgets'] as List)
          .map((e) => LabelWidget.fromJson(e as Map<String, dynamic>))
          .toList();
      return LabelTemplate(
        templateName: json['templateName'] as String,
        version: json['version'] as String? ?? '1.0',
        canvasProperties: CanvasProperties.fromJson(
          json['canvasProperties'] as Map<String, dynamic>,
        ),
        pages: [LabelPage(id: 'page_1', widgets: widgetsList)],
      );
    }
    return _$LabelTemplateFromJson(json);
  }
  Map<String, dynamic> toJson() => _$LabelTemplateToJson(this);
}
