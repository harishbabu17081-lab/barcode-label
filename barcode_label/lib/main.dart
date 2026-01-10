import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/editor_screen.dart';
import 'providers/canvas_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarcodeLabelApp());
}

class BarcodeLabelApp extends StatelessWidget {
  const BarcodeLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Color Palette
    const primaryColor = Color(0xFF6366F1); // Indigo
    const secondaryColor = Color(0xFF0EA5E9); // Sky Blue
    const surfaceColor = Colors.white;
    const backgroundColor = Color(0xFFF8FAFC); // Slate 50
    const errorColor = Color(0xFFEF4444); // Red 500

    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CanvasProvider())],
      child: MaterialApp(
        title: 'Barcode Label Designer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            error: errorColor,
            // background: backgroundColor, // Background is surface in M3 usually, but scaffold needs tint
          ),
          scaffoldBackgroundColor: backgroundColor,
          textTheme: textTheme.apply(
            bodyColor: const Color(0xFF1E293B), // Slate 800
            displayColor: const Color(0xFF0F172A), // Slate 900
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: surfaceColor,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF64748B),
            ), // Slate 500
          ),
          // cardTheme: CardTheme(
          //   color: surfaceColor,
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //   shadowColor: Colors.black.withOpacity(0.05),
          // ),
          // dialogTheme: DialogTheme(
          //   backgroundColor: surfaceColor,
          //   elevation: 5,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          //   titleTextStyle: textTheme.headlineSmall?.copyWith(
          //     fontWeight: FontWeight.bold,
          //     color: const Color(0xFF0F172A),
          //   ),
          // ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F9), // Slate 100
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: const TextStyle(color: Color(0xFF64748B)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B), // Slate 500
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
        ),
        home: const EditorScreen(),
      ),
    );
  }
}
