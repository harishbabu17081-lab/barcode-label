import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../providers/canvas_provider.dart';
import '../models/canvas_model.dart';
import '../models/widget_model.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        final props = provider.template.canvasProperties;
        // Simple scaling: 1mm = 3.78px, 1 inch = 96px
        final double scale = props.units == LabelUnits.mm ? 3.78 : 96.0;
        final double width = props.width * scale;
        final double height = props.height * scale;

        Color bgColor;
        try {
          bgColor = Color(
            int.parse(props.backgroundColor.replaceFirst('#', '0xFF')),
          );
        } catch (e) {
          bgColor = Colors.white;
        }

        return Container(
          color: Colors.grey[300],
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DragTarget<WidgetType>(
                  onAcceptWithDetails: (details) {
                    final RenderBox? renderBox =
                        _canvasKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (renderBox != null) {
                      final localOffset = renderBox.globalToLocal(
                        details.offset,
                      );

                      // Calculate default properties based on type
                      Map<String, dynamic> initialProps = {};
                      double defaultW = 100;
                      double defaultH = 50;

                      switch (details.data) {
                        case WidgetType.text:
                          initialProps = {
                            'content': 'New Text',
                            'fontSize': 20.0,
                            'fontFamily': 'Roboto',
                          };
                          defaultW = 120;
                          defaultH = 40;
                          break;
                        case WidgetType.barcode:
                          initialProps = {
                            'data': '12345678',
                            'barcodeType': 'Code128',
                          };
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

                      provider.addWidget(
                        LabelWidget(
                          type: details.data,
                          position: WidgetPosition(
                            x: localOffset.dx,
                            y: localOffset.dy,
                            width: defaultW,
                            height: defaultH,
                          ),
                          properties: initialProps,
                        ),
                      );
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      key: _canvasKey,
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: bgColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ...provider.template.widgets.map((widget) {
                            return Positioned(
                              left: widget.position.x,
                              top: widget.position.y,
                              child: _WidgetRenderer(widget: widget),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WidgetRenderer extends StatelessWidget {
  final LabelWidget widget;

  const _WidgetRenderer({required this.widget});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CanvasProvider>(context, listen: false);
    // Listen to selection changes from provider?
    // Actually, we are inside Consumer in parent, but this widget is not rebuilding when selection changes unless parent rebuilds.
    // Parent rebuilds on any notifyListeners.

    final isSelected = context.select<CanvasProvider, bool>(
      (p) => p.selectedWidgetId == widget.id,
    );

    return GestureDetector(
      onTap: () => provider.selectWidget(widget.id),
      onPanUpdate: isSelected
          ? (details) {
              provider.updateWidgetPosition(
                widget.id,
                WidgetPosition(
                  x: widget.position.x + details.delta.dx,
                  y: widget.position.y + details.delta.dy,
                  width: widget.position.width,
                  height: widget.position.height,
                  rotation: widget.position.rotation,
                ),
              );
            }
          : null,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(border: Border.all(color: Colors.blue, width: 2))
            : null,
        width: widget.position.width,
        height: widget.position.height,
        child: _renderContent(widget),
      ),
    );
  }

  Widget _renderContent(LabelWidget widget) {
    if (widget.type == WidgetType.text) {
      return Text(
        widget.properties['content'] ?? 'Text',
        style: TextStyle(
          fontSize: (widget.properties['fontSize'] as num?)?.toDouble() ?? 14,
          fontFamily: widget.properties['fontFamily'] as String?,
        ),
      );
    } else if (widget.type == WidgetType.barcode) {
      return BarcodeWidget(
        barcode: Barcode.code128(), // Dynamic later
        data: widget.properties['data'] ?? '123456',
        width: widget.position.width,
        height: widget.position.height,
      );
    } else if (widget.type == WidgetType.shape) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
      );
    }
    return const Placeholder();
  }
}
