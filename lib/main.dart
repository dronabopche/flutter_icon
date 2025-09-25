import 'package:flutter/material.dart';
import 'package:icon_flutter/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project credentials
  await Supabase.initialize(
    url:
        'https://rcyjmwhtufviacitmxkg.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjeWptd2h0dWZ2aWFjaXRteGtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNzU2ODcsImV4cCI6MjA3Mzg1MTY4N30.e36Mp1KKI1s3BkZzGxrADa-Hk3V0H11-S3LZobFHXlE', // Replace with your Supabase anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIF Library App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
