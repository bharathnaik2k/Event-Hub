import 'package:eventhub/firebase_options.dart';
import 'package:eventhub/src/router/router_path.dart';
import 'package:eventhub/src/screens/auth_screen.dart';
import 'package:eventhub/src/screens/help_support_screen.dart';
import 'package:eventhub/src/screens/home_screen.dart';
import 'package:eventhub/src/screens/my_event_screen.dart';
import 'package:eventhub/src/screens/update_name_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //     statusBarIconBrightness: Brightness.light, // for Android
  //     statusBarBrightness: Brightness.light, // for iOS
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C27B0)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // Android icons
            statusBarBrightness: Brightness.light, // iOS text
          ),
        ),
      ),
      initialRoute: '/authWrapper',
      routes: {
        '/authWrapper': (context) => const AuthWrapper(),
        '/authScreen': (context) => const AuthScreen(),
        '/routerPath': (context) => const RouterPath(),
        '/homeScreen': (context) => HomeScreen(),
        '/myEventScreen': (context) => const MyEventScreen(),
        '/updateNameScreen': (context) => const UpdateNameScreen(),
        '/helpAndSupport': (context) => const HelpSupportScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const RouterPath();
        }
        return const AuthScreen();
      },
    );
  }
}
