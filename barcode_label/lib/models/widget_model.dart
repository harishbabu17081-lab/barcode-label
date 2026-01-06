import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'widget_model.g.dart';

enum WidgetType { text, barcode, shape, image }

@JsonSerializable()
class WidgetPosition {
  double x;
  double y;
  double width;
  double height;
  double rotation;

  WidgetPosition({
    this.x = 0,
    this.y = 0,
    this.width = 100,
    this.height = 50,
    this.rotation = 0,
  });

  factory WidgetPosition.fromJson(Map<String, dynamic> json) => _$WidgetPositionFromJson(json);
  Map<String, dynamic> toJson() => _$WidgetPositionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LabelWidget {
  String id;
  WidgetType type;
  WidgetPosition position;
  Map<String, dynamic> properties;

  LabelWidget({
    String? id,
    required this.type,
    required this.position,
    required this.properties,
  }) : id = id ?? const Uuid().v4();

  factory LabelWidget.fromJson(Map<String, dynamic> json) => _$LabelWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$LabelWidgetToJson(this);
}
