import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_rumble/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color darkGreen = Color(0xFF14361F);
  static const Color mediumGreen = Color(0xFF3E7B27);
  static const Color lightGreen = Color(0xFF8DC63F);
  static const Color fieldBorder = Color(0xFFE0E0DA);
  static const Color hintGrey = Color(0xFF8A8A85);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    final loginInput = _emailController.text.trim();
    final password = _passwordController.text;

    // ---------------- VALIDATION ----------------

    if (loginInput.isEmpty) {
      _showMessage('Please enter your email or phone number.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String email = loginInput;

      // ========================================================
      // IF USER ENTERED PHONE NUMBER
      // ========================================================

      if (!loginInput.contains('@')) {
        final userQuery = await _firestore
            .collection('users')
            .where('phone', isEqualTo: loginInput)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          throw Exception('No account found with this phone number.');
        }

        final userData = userQuery.docs.first.data();

        final storedEmail = userData['email'];

        if (storedEmail == null ||
            storedEmail.toString().trim().isEmpty) {
          throw Exception(
            'This account does not have a valid email address.',
          );
        }

        email = storedEmail.toString().trim();
      }

      // ========================================================
      // FIREBASE AUTH LOGIN
      // ========================================================

      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // ========================================================
      // CHECK USER DOCUMENT
      // users/{uid}
      // ========================================================

      final userDocument = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {
        // The Firebase Auth account exists,
        // but the Firestore profile does not.
        debugPrint(
          'Warning: users/${user.uid} does not exist in Firestore.',
        );
      }

      if (!mounted) return;

      _showMessage(
        'Welcome back!',
        success: true,
      );

      // Small delay so user can see success message.
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // ========================================================
      // GO TO HOME
      // ========================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const Navbar(0, true),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email/phone or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message =
          'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _handleForgotPassword() async {
    final input = _emailController.text.trim();

    if (input.isEmpty) {
      _showMessage(
        'Enter your email address first.',
      );
      return;
    }

    // Password reset requires an email.
    if (!input.contains('@')) {
      _showMessage(
        'Please enter your email address to reset your password.',
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: input,
      );

      if (!mounted) return;

      _showMessage(
        'Password reset email sent. Check your inbox.',
        success: true,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        default:
          message =
              e.message ?? 'Could not send password reset email.';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Something went wrong. Please try again.',
        );
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          success ? mediumGreen : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/logoback.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================

                  const Icon(
                    Icons.eco,
                    size: 56,
                    color: mediumGreen,
                  ),

                  const SizedBox(height: 8),

                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      children: [
                        TextSpan(
                          text: 'AGRO',
                          style: TextStyle(
                            color: darkGreen,
                          ),
                        ),
                        TextSpan(
                          text: 'VA',
                          style: TextStyle(
                            color: lightGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 1,
                        color: darkGreen,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          'GROWING TOGETHER, FOR A BETTER TOMORROW',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                            color: darkGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 1,
                        color: darkGreen,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Login to continue to your account',
                    style: TextStyle(
                      fontSize: 15,
                      color: hintGrey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // EMAIL / PHONE
                  // ==================================================

                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email or Phone',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: hintGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // FORGOT PASSWORD
                  // ==================================================

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: mediumGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        disabledBackgroundColor:
                        darkGreen.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child:
                      _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SIGN UP
                  // ==================================================

                  GestureDetector(
                    onTap: () {
                      // TODO:
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const SignUpScreen(),
                      //   ),
                      // );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: hintGrey,
                        ),
                        children: [
                          TextSpan(
                            text:
                            "Don't have an account? ",
                          ),
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: mediumGreen,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: darkGreen,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: const TextStyle(
          color: hintGrey,
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(30),
          borderSide:
          const BorderSide(
            color: fieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(30),
          borderSide:
          const BorderSide(
            color: fieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(30),
          borderSide:
          const BorderSide(
            color: mediumGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}