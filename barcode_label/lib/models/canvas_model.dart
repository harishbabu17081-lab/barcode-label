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
    this.width = 100,
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
class LabelTemplate {
  String templateName;
  String version;
  CanvasProperties canvasProperties;
  List<LabelWidget> widgets;

  LabelTemplate({
    required this.templateName,
    this.version = '1.0',
    required this.canvasProperties,
    required this.widgets,
  });

  factory LabelTemplate.fromJson(Map<String, dynamic> json) =>
      _$LabelTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$LabelTemplateToJson(this);
}
