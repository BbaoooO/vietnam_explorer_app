import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryColor = Color(0xFF0F4C3A);
  static const Color secondaryColor = Color(0xFFF2B705);

  bool _isLogin = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final confirmPassword = _confirmPasswordController.text.trim();
        if (password != confirmPassword) {
          _showMessage('Passwords do not match', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showMessage('Registration successful! Logging in...');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password must be at least 6 characters';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }
      _showMessage(errorMessage, isError: true);
    } catch (e) {
      _showMessage('An unexpected error occurred', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPasswordReset() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _PasswordResetDialog(initialEmail: _emailController.text.trim()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1555921015-5532091f6026?w=800',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: primaryColor.withValues(alpha: 0.7)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.explore, size: 80, color: secondaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Vietnam Explorer',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Be Vietnam Pro',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Welcome back, Explorer!'
                          : 'Start your journey today',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),

                    _buildTextField(
                      _emailController,
                      Icons.email_outlined,
                      'Email Address',
                      false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordController,
                      Icons.lock_outline,
                      'Password',
                      true,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        _confirmPasswordController,
                        Icons.lock_outline,
                        'Confirm Password',
                        true,
                      ),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: primaryColor,
                              )
                            : Text(
                                _isLogin ? 'Log In' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (_isLogin)
                      TextButton(
                        onPressed: _isLoading ? null : _openPasswordReset,
                        style: TextButton.styleFrom(
                          foregroundColor: secondaryColor,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _emailController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            });
                          },
                          child: Text(
                            _isLogin ? 'Register' : 'Log In',
                            style: const TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }
}

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  late final _email = TextEditingController(text: widget.initialEmail);
  final _form = GlobalKey<FormState>();
  bool _sending = false;
  bool _complete = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || _complete || !_form.currentState!.validate()) return;
    final email = _email.text.trim();
    setState(() {
      _sending = true;
      _error = null;
    });
    String? error;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (exception) {
      error = switch (exception.code) {
        'user-not-found' => null,
        'invalid-email' => 'Enter a valid email address.',
        'too-many-requests' => 'Too many requests. Please try again later.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        _ => 'Could not send a reset link. Please try again.',
      };
    } catch (_) {
      error = 'Could not send a reset link. Please try again.';
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = error;
      _complete = error == null;
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_sending,
    child: AlertDialog(
      title: Text(_complete ? 'Check your inbox' : 'Reset your password'),
      scrollable: true,
      content: _complete
          ? const Text(
              'If an account exists for this email, you will receive a password reset link. Check your spam folder too.',
            )
          : Form(
              key: _form,
              child: TextFormField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !_sending,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onFieldSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  labelText: 'Email address',
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                      ? null
                      : 'Enter a valid email address.';
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: Text(_complete ? 'Done' : 'Cancel'),
        ),
        if (!_complete)
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(_sending ? 'Sending…' : 'Send reset link'),
          ),
      ],
    ),
  );
}
