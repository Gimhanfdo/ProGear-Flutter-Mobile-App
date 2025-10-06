import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/navigation_wrapper.dart';
import 'package:progear_mobileapp/screens/register.dart';
import 'package:progear_mobileapp/screens/shared/button.dart';
import 'package:progear_mobileapp/screens/shared/error_alert_dialog.dart';
import 'package:progear_mobileapp/screens/shared/text_field.dart';
import 'package:progear_mobileapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      showErrorAlertDialog(context, 'Please enter email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final success = await authService.login(email, password);

    if (!mounted) return; 

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationWrapper()),
      );
    } else {
      showErrorAlertDialog(context, 'Invalid email or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  'PROGEAR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  labelText: 'Email',
                  textController: emailController,
                  hintText: 'Enter your email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Password',
                  textController: passwordController,
                  hintText: 'Enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.teal[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Sign in button
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        buttonText: 'Sign In',
                        buttonColor: Colors.teal.shade600,
                        onTap: login, 
                      ),

                const SizedBox(height: 25),

                // Sign in with Google button (placeholder)
                CustomButton(
                  buttonText: 'Sign In with Google',
                  buttonColor: Colors.grey.shade800,
                  iconPath: 'assets/icons/google.png',
                  onTap: () {
                    // Google auth integration
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not registered yet?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Sign up now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
