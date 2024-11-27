import 'package:flutter/material.dart';
import 'package:lista_compras_flutter/data/premium_service.dart';
import 'package:lista_compras_flutter/screens/initial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os widgets sejam inicializados antes do Mobile Ads
  //await MobileAds.instance.initialize(); // Inicializa o SDK do Google Mobile Ads
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final bool premium = await PremiumService.isPremiumUser();
    setState(() {
      isPremiumUser = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: InitialScreen(isPremiumUser: isPremiumUser),
    );
  }
}
