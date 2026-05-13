import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_util.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    final String? passwordError = Validators.password(value);
    if (passwordError != null) {
      return passwordError;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool success = await authProvider.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      SnackBarUtil.showError(
        context,
        authProvider.errorMessage ?? 'Unable to sign up',
      );
      return;
    }
    SnackBarUtil.showMessage(context, 'Account created successfully');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isCompact ? width : 420),
            child: Form(
              key: _formKey,
              child: Consumer<AuthProvider>(
                builder: (_, AuthProvider authProvider, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppConstants.signupTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to track your tasks.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        obscureText: true,
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleSignup,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
