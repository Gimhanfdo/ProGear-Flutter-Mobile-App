import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/shared/button.dart';
import 'package:progear_mobileapp/screens/shared/error_alert_dialog.dart';
import 'package:progear_mobileapp/screens/shared/text_field.dart';
import 'package:progear_mobileapp/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  String? validateFields() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'All fields are required.';
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    if (password.length < 6 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must be at least 6 characters long and contain at least one uppercase, one digit, and one special character.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    return null; // no errors
  }

  Future<void> signUp() async {
    final error = validateFields();
    if (error != null) {
      if (!mounted) return;
      showErrorAlertDialog(context, error);
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    final success = await authService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('PROGEAR'),
              content: const Text("Registration successful! Please login."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // close dialog
                    Navigator.pop(context); // back to login
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      showErrorAlertDialog(context, 'Registration failed. Please try again.');
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
                  'Create your account now',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  labelText: 'Full Name',
                  textController: nameController,
                  hintText: 'Enter your full name',
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  labelText: 'Email Address',
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

                CustomTextField(
                  labelText: 'Confirm Password',
                  textController: confirmPasswordController,
                  hintText: 'Re-enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                      buttonText: 'Sign Up',
                      buttonColor: Colors.teal.shade600,
                      onTap: () => signUp(),
                    ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
