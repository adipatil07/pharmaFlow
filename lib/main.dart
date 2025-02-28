import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/features/auth/splash_screen.dart';
import 'package:pharma_supply/features/manufacturer/notifier/manufacturer_notifier.dart';
import 'package:pharma_supply/features/patient/add_order_notifier.dart';
import 'package:pharma_supply/features/patient/patient_home_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyBH3jxa9nUJ7uExJvJ6dfkzRsFMVYvC5qI",
    appId: "1:850118060878:android:065c67a2c03c910003cc1f",
    messagingSenderId: "1:850118060878:android:065c67a2c03c910003cc1f",
    projectId: "pharmacysupplymanagement",
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ManufacturerNotifier()),
        ChangeNotifierProvider(create: (_) => AddOrderNotifier()),
        ChangeNotifierProvider(create: (_) => PatientHomeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaFlow',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
