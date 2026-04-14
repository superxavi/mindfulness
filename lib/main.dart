import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';

/// Application entry point.
/// Initializes Supabase before running the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with configuration placeholders.
  // Replace values using --dart-define or a secure dotenv loader in development.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tesis Mindfulness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Keep Spanish UI strings; business logic and comments are in English.
      home: const MainScreen(),
    );
  }
}

// --- UI LAYER (Spanish text for end users) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  // Builds the top app bar.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mindfulness App'),
      backgroundColor: Colors.teal.shade100,
      centerTitle: true,
    );
  }

  // Builds the main body with Spanish UI strings.
  Widget _buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Column(
      children: [
        Icon(Icons.self_improvement, size: 80, color: Colors.teal),
        SizedBox(height: 10),
        Text(
          'Bienvenido a tu sesión',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: () => print('Iniciando meditación...'),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Comenzar Meditación'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}
