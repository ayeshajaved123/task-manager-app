import 'package:flutter/material.dart';
import 'package:smart_community_safety/screens/login_screen.dart';
import 'package:smart_community_safety/services/auth_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/widgets/custom_button.dart';
import 'package:smart_community_safety/widgets/custom_textfield.dart';
import 'package:smart_community_safety/screens/dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      Helpers.showSnackbar(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService().signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
    );
    setState(() => _isLoading = false);

    if (error == null) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Account Created!'),
          content: const Text('Your account has been created successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Helpers.showSnackbar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                prefixIcon: const Icon(Icons.account_circle_outlined), // ✅ Built-in
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                validator: Helpers.validateEmail,
                prefixIcon: const Icon(Icons.email_outlined), // ✅ Built-in
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone (Optional)',
                controller: _phoneController,
                prefixIcon: const Icon(Icons.phone_outlined), // ✅ Built-in
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                validator: Helpers.validatePassword,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline), // ✅ Built-in
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_clock_outlined), // ✅ Built-in
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Account',
                onPressed: _signup,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}