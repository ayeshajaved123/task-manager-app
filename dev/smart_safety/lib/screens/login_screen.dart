import 'package:flutter/material.dart';
import 'package:smart_community_safety/screens/signup_screen.dart';
import 'package:smart_community_safety/screens/dashboard_screen.dart';
import 'package:smart_community_safety/services/auth_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/widgets/custom_button.dart';
import 'package:smart_community_safety/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await AuthService().signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    // ✅ THIS IS THE CRITICAL PART
    if (error == null) {
      if (!mounted) return;

      print("✅ Login successful");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Helpers.showSnackbar(context, error);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                validator: Helpers.validateEmail,
                prefixIcon: const Icon(Icons.email_outlined), // ✅ Built-in
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                validator: Helpers.validatePassword,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline), // ✅ Built-in
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign In',
                onPressed: _login,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    Helpers.slideRightRoute(builder: (_) => const SignupScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_outlined), // ✅ Built-in
                label: const Text('Don’t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}