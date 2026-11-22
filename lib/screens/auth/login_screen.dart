import 'package:flutter/material.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/screens/auth/auth_validators.dart';
import 'package:expense_tracker/screens/auth/password_form_field.dart';
import 'package:expense_tracker/screens/auth/signup_screen.dart';
import 'package:expense_tracker/screens/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      // after the first failed try, errors update while the user types
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    // UI-only: no real authentication in Step 2
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.sectionSpacing),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Image(
                            image: AssetImage(
                              'assets/images/spendwise_mark.png',
                            ),
                            height: 64,
                            semanticLabel: 'SpendWise logo',
                          ),
                          const SizedBox(height: AppTheme.pagePadding),
                          Text(
                            'SpendWise',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: AuthValidators.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: AppTheme.pagePadding),
                          PasswordFormField(
                            controller: _passwordController,
                            label: 'Password',
                            validator: AuthValidators.loginPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppTheme.sectionSpacing),
                          FilledButton(
                            onPressed: _submit,
                            child: const Text('Log in'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text("Don't have an account? Sign up"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
