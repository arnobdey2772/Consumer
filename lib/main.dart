import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_screen.dart';
import 'region_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hxjkomcynnbardxmooew.supabase.co', 
    anonKey: 'sb_publishable_crNXvspOSPLc30yQHnWcoA_Ze8AwSDL'
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegionProvider()),
      ],
      child: const ConsumerGuardianApp(),
    ),
  );
}

class ConsumerGuardianApp extends StatelessWidget {
  const ConsumerGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consumer Guardian BD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
//ami argho