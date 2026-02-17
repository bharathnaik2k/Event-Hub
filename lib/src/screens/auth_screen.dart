import 'package:eventhub/src/auth/auth_services.dart';
import 'package:eventhub/src/utils/constants.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(84, 255, 255, 255),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset('assets/images/logo84kb.png'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Event Hub',
                  style: GoogleFonts.courgette(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover nearby events & meetups',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 90),
                TextButton(
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.all(14)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(255, 0, 0, 0),
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(255, 230, 230, 230),
                    ),
                  ),
                  onPressed: () async {
                    _isLoading.value = false;

                    if (!_isLoading.value) {
                      await OAuthService().oAuthSignIn();
                    }
                    if (mounted) _isLoading.value = true;
                  },

                  child: ValueListenableBuilder(
                    valueListenable: _isLoading,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !value
                              ? SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                              : SvgPicture.asset(
                                'assets/svg/google.svg',
                                width: 20,
                                height: 20,
                              ),

                          if (value) SizedBox(width: 5),
                          if (value)
                            Text(
                              "Continue with Google",
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
