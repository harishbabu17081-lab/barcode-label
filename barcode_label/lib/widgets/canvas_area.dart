import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart'; // for kIsWeb
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
          color: Theme.of(context).scaffoldBackgroundColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - 80, // Subtract padding
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Vertically center
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Horizontally center
                        children: [
                          ...provider.template.pages.map((page) {
                            return Padding(
                              key: ValueKey(
                                page.id,
                              ), // Add Key to prevent rebuild issues
                              padding: const EdgeInsets.only(bottom: 40),
                              child: _buildPage(
                                context,
                                provider,
                                page,
                                width,
                                height,
                                bgColor,
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          // Auto-Add Page Drop Zone
                          _buildNewPageDropZone(
                            context,
                            provider,
                            width,
                            height,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNewPageDropZone(
    BuildContext context,
    CanvasProvider provider,
    double width,
    double height,
  ) {
    return DragTarget<WidgetType>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        provider.addPage(); 


        final widget = createDefaultWidget(details.data, const Offset(20, 20));
        provider.addWidget(widget);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('New page created!')));
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: width,
          height: 100, 
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 2,
              style: BorderStyle
                  .none, 
            
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey, size: 32),
              SizedBox(height: 8),
              Text(
                'Drop here to add new page',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    CanvasProvider provider,
    LabelPage page,
    double width,
    double height,
    Color bgColor,
  ) {
    final isActive = provider.activePageId == page.id;

    return GestureDetector(
      onTap: () {
        provider.setActivePage(page.id);
        provider.selectWidget(null); 
      },
      child: _PageContainer(
        page: page,
        width: width,
        height: height,
        bgColor: bgColor,
        isActive: isActive,
      ),
    );
  }
}

class _PageContainer extends StatefulWidget {
  final LabelPage page;
  final double width;
  final double height;
  final Color bgColor;
  final bool isActive;

  const _PageContainer({
    required this.page,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.isActive,
  });

  @override
  State<_PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<_PageContainer> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<CanvasProvider>();

    return DragTarget<WidgetType>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(details.offset);

        provider.setActivePage(widget.page.id);
        _addWidget(provider, details.data, localOffset);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.bgColor,
            border: widget.isActive
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...widget.page.widgets.map((labelWidget) {
                return Positioned(
                  left: labelWidget.position.x,
                  top: labelWidget.position.y,
                  child: _WidgetRenderer(widget: labelWidget),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _addWidget(CanvasProvider provider, WidgetType type, Offset position) {
    final widget = createDefaultWidget(type, position);
    provider.addWidget(widget);
  }
}
LabelWidget createDefaultWidget(WidgetType type, Offset position) {
  Map<String, dynamic> initialProps = {};
  double defaultW = 100;
  double defaultH = 50;

  switch (type) {
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
      initialProps = {'data': '12345678', 'barcodeType': 'Code128'};
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

  return LabelWidget(
    type: type,
    position: WidgetPosition(
      x: position.dx,
      y: position.dy,
      width: defaultW,
      height: defaultH,
    ),
    properties: initialProps,
  );
}

class _WidgetRenderer extends StatelessWidget {
  final LabelWidget widget;

  const _WidgetRenderer({required this.widget});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CanvasProvider>(context, listen: false);
    final isSelected = context.select<CanvasProvider, bool>(
      (p) => p.selectedWidgetId == widget.id,
    );

    return GestureDetector(
      onTap: () => provider.selectWidget(widget.id),
      onPanStart: (_) {
        provider.prepareUndo();
        provider.selectWidget(widget.id);
      },
      onPanUpdate: (details) {

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
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(border: Border.all(color: Colors.blue, width: 2))
            : BoxDecoration(
                border: Border.all(color: Colors.transparent, width: 2),
              ),
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
          color: widget.properties['color'] is int
              ? Color(widget.properties['color'])
              : Colors.black,
        ),
      );
    } else if (widget.type == WidgetType.barcode) {
      final color = widget.properties['color'] is int
          ? Color(widget.properties['color'])
          : Colors.black;
      return BarcodeWidget(
        barcode: Barcode.code128(),
        data: widget.properties['data'] ?? '123456',
        color: color,
        style: TextStyle(color: color),
        width: widget.position.width,
        height: widget.position.height,
      );
    } else if (widget.type == WidgetType.shape) {
      final props = widget.properties;
      final strokeColor = props['strokeColor'] is int
          ? Color(props['strokeColor'])
          : (props['strokeColor'] is String
                ? Color(
                    int.parse(
                      props['strokeColor'].toString().replaceFirst('#', '0xFF'),
                    ),
                  )
                : Colors.black);
      final filled = props['filled'] == true;
      final fillColor = props['fillColor'] is int
          ? Color(props['fillColor'])
          : Colors.transparent;
      final strokeWidth = (props['strokeWidth'] as num?)?.toDouble() ?? 2.0;
      final radius = (props['borderRadius'] as num?)?.toDouble() ?? 0.0;

      return Container(
        decoration: BoxDecoration(
          color: filled ? fillColor : null,
          border: Border.all(color: strokeColor, width: strokeWidth),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    } else if (widget.type == WidgetType.image) {
      if (widget.properties['path'] != null) {
        if (kIsWeb) {
          return Image.network(
            widget.properties['path'],
            width: widget.position.width,
            height: widget.position.height,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, size: 40));
            },
          );
        } else {
          return Image.file(
            File(widget.properties['path']),
            width: widget.position.width,
            height: widget.position.height,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, size: 40));
            },
          );
        }
      } else {
        return const Center(
          child: Icon(Icons.image, size: 50, color: Colors.grey),
        );
      }
    }
    return const Placeholder();
  }
}
