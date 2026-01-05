import 'package:codebloom/pages/home/home.dart';
import 'package:codebloom/pages/profile/complete_profile_screen.dart';
import 'package:codebloom/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'pages/login/login_screen.dart';
import 'services/notification_services.dart' hide NotificationService;   // <-- IMPORTANT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Initialize Notification Service
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeBloom',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        fontFamily: 'Outfit',
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data as User;

        return FutureBuilder(
          future: user.reload(),
          builder: (context, reloadSnap) {
            if (reloadSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (reloadSnap.hasError) {
              final error = reloadSnap.error;

              if (error is FirebaseAuthException &&
                  error.code == 'user-not-found') {
                FirebaseAuth.instance.signOut();
                return const LoginScreen();
              }
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, docSnap) {
                if (docSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!docSnap.hasData || !docSnap.data!.exists) {
                  return const CompleteProfileScreen();
                }

                final data =
                    docSnap.data!.data() as Map<String, dynamic>? ?? {};

                if (data['profileCompleted'] != true) {
                  return const CompleteProfileScreen();
                }

                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}
