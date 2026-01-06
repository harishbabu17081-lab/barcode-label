// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetPosition _$WidgetPositionFromJson(Map<String, dynamic> json) =>
    WidgetPosition(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 50,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$WidgetPositionToJson(WidgetPosition instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'rotation': instance.rotation,
    };

LabelWidget _$LabelWidgetFromJson(Map<String, dynamic> json) => LabelWidget(
  id: json['id'] as String?,
  type: $enumDecode(_$WidgetTypeEnumMap, json['type']),
  position: WidgetPosition.fromJson(json['position'] as Map<String, dynamic>),
  properties: json['properties'] as Map<String, dynamic>,
);

Map<String, dynamic> _$LabelWidgetToJson(LabelWidget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$WidgetTypeEnumMap[instance.type]!,
      'position': instance.position.toJson(),
      'properties': instance.properties,
    };

const _$WidgetTypeEnumMap = {
  WidgetType.text: 'text',
  WidgetType.barcode: 'barcode',
  WidgetType.shape: 'shape',
  WidgetType.image: 'image',
};
