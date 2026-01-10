// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanvasProperties _$CanvasPropertiesFromJson(Map<String, dynamic> json) =>
    CanvasProperties(
      width: (json['width'] as num?)?.toDouble() ?? 150,
      height: (json['height'] as num?)?.toDouble() ?? 150,
      orientation:
          $enumDecodeNullable(_$LabelOrientationEnumMap, json['orientation']) ??
          LabelOrientation.portrait,
      units:
          $enumDecodeNullable(_$LabelUnitsEnumMap, json['units']) ??
          LabelUnits.mm,
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
    );

Map<String, dynamic> _$CanvasPropertiesToJson(CanvasProperties instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'orientation': _$LabelOrientationEnumMap[instance.orientation]!,
      'units': _$LabelUnitsEnumMap[instance.units]!,
      'backgroundColor': instance.backgroundColor,
    };

const _$LabelOrientationEnumMap = {
  LabelOrientation.portrait: 'portrait',
  LabelOrientation.landscape: 'landscape',
};

const _$LabelUnitsEnumMap = {LabelUnits.mm: 'mm', LabelUnits.inches: 'inches'};

LabelPage _$LabelPageFromJson(Map<String, dynamic> json) => LabelPage(
  id: json['id'] as String,
  widgets: (json['widgets'] as List<dynamic>)
      .map((e) => LabelWidget.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LabelPageToJson(LabelPage instance) => <String, dynamic>{
  'id': instance.id,
  'widgets': instance.widgets.map((e) => e.toJson()).toList(),
};

LabelTemplate _$LabelTemplateFromJson(Map<String, dynamic> json) =>
    LabelTemplate(
      templateName: json['templateName'] as String,
      version: json['version'] as String? ?? '1.0',
      canvasProperties: CanvasProperties.fromJson(
        json['canvasProperties'] as Map<String, dynamic>,
      ),
      pages: (json['pages'] as List<dynamic>)
          .map((e) => LabelPage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LabelTemplateToJson(LabelTemplate instance) =>
    <String, dynamic>{
      'templateName': instance.templateName,
      'version': instance.version,
      'canvasProperties': instance.canvasProperties.toJson(),
      'pages': instance.pages.map((e) => e.toJson()).toList(),
    };
