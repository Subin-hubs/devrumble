import 'package:dev_rumble/navbar.dart';
import 'package:dev_rumble/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../home/home.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  static const Color darkGreen = Color(0xFF14361F);
  static const Color mediumGreen = Color(0xFF3E7B27);
  static const Color lightGreen = Color(0xFF8DC63F);
  static const Color fieldBorder = Color(0xFFE0E0DA);
  static const Color hintGrey = Color(0xFF8A8A85);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password needs at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password needs at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password needs at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
      return 'Password needs at least one special character';
    }

    return null;
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _handleCreateAccount() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    try {
      // 1. Create Firebase Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user!;

      debugPrint('USER CREATED: ${user.uid}');

      // 2. Store user information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('USER DATA SAVED TO FIRESTORE');

      if (!mounted) return;

      // 3. Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Navbar(0, true),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${e.code}: ${e.message ?? "Unknown Firebase error"}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('GENERAL ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/logback.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    Center(
                      child: Column(
                        children: [
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
                                fontWeight:
                                FontWeight.bold,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Join Agrova and grow with us.',
                        style: TextStyle(
                          fontSize: 15,
                          color: hintGrey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // FULL NAME
                    // ==================================================

                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }

                        if (value.trim().length < 2) {
                          return 'Please enter a valid name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email Address',
                      icon: Icons.mail_outline,
                      keyboardType:
                      TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(
                          value.trim(),
                        )) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // PHONE
                    // ==================================================

                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType:
                      TextInputType.phone,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }

                        final phoneRegex = RegExp(
                          r'^[0-9]{7,15}$',
                        );

                        if (!phoneRegex.hasMatch(
                          value.trim(),
                        )) {
                          return 'Enter a valid phone number';
                        }

                        return null;
                      },
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
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                              .visibility_off_outlined
                              : Icons
                              .visibility_outlined,
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

                    const SizedBox(height: 8),

                    // Password requirements

                    const Padding(
                      padding: EdgeInsets.only(
                        left: 4,
                      ),
                      child: Text(
                        'Password: 8+ characters, uppercase, lowercase, number & special character',
                        style: TextStyle(
                          fontSize: 11,
                          color: hintGrey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

                    _buildTextField(
                      controller:
                      _confirmPasswordController,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText:
                      _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value !=
                            _passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                              .visibility_off_outlined
                              : Icons
                              .visibility_outlined,
                          color: hintGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // TERMS
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                              setState(() {
                                _agreedToTerms =
                                    value ?? false;
                              });
                            },
                            activeColor: mediumGreen,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                              top: 4,
                            ),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hintGrey,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                    'I agree to the ',
                                  ),
                                  TextSpan(
                                    text:
                                    'Terms & Conditions',
                                    style: TextStyle(
                                      color:
                                      mediumGreen,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text:
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color:
                                      mediumGreen,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CREATE ACCOUNT BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _handleCreateAccount,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          disabledBackgroundColor:
                          darkGreen.withOpacity(
                            0.5,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Create Account',
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
                    // DIVIDER
                    // ==================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: fieldBorder,
                            thickness: 1,
                          ),
                        ),
                        const Padding(
                          padding:
                          EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: hintGrey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: fieldBorder,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // LOGIN
                    // ==================================================

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: hintGrey,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Already have an account? ',
                            ),
                            TextSpan(
                              text: 'Log in',
                              style: const TextStyle(
                                color: mediumGreen,
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
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
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: fieldBorder,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: fieldBorder,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: mediumGreen,
            width: 1.5,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}