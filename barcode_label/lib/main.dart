import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/editor_screen.dart';
import 'providers/canvas_provider.dart';

void main() {
  runApp(const BarcodeLabelApp());
}

class BarcodeLabelApp extends StatelessWidget {
  const BarcodeLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CanvasProvider())],
      child: MaterialApp(
        title: 'Barcode Label Designer',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const EditorScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
