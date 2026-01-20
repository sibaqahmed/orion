import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.signupWithEmail(
        email: _email.text.trim(),
        password: _pass.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.85),
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.55),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(prefix, color: AppColors.textSecondary.withOpacity(0.85)),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface.withOpacity(0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.accent.withOpacity(0.10),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.accent.withOpacity(0.35),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _glowOrb() {
    return Container(
      height: 84,
      width: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withOpacity(0.55),
            AppColors.primary.withOpacity(0.28),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withOpacity(0.75),
            border: Border.all(color: AppColors.accent.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.textPrimary.withOpacity(0.95),
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -140,
            left: -120,
            child: Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -170,
            right: -120,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.14),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),

                      // Top row: back + spacer (more premium feel)
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _loading ? null : () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.10),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Hero header
                      Center(child: _glowOrb()),
                      const SizedBox(height: 12),

                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            colors: [
                              AppColors.textPrimary,
                              AppColors.accent.withOpacity(0.95),
                            ],
                          ).createShader(rect);
                        },
                        child: const Text(
                          "ORION",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create your account to save chats and sync across devices.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.2,
                          height: 1.45,
                          color: AppColors.textSecondary.withOpacity(0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Main card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.surface.withOpacity(0.78),
                              AppColors.surface.withOpacity(0.50),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.30),
                              blurRadius: 26,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "It only takes a minute.",
                                style: TextStyle(
                                  color:
                                  AppColors.textSecondary.withOpacity(0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Email
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _fieldDecoration(
                                  label: "Email",
                                  hint: "you@example.com",
                                  prefix: Icons.mail_outline_rounded,
                                ),
                                validator: (v) {
                                  final s = (v ?? "").trim();
                                  if (s.isEmpty) return "Email is required";
                                  if (!s.contains("@") || !s.contains(".")) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password
                              TextFormField(
                                controller: _pass,
                                obscureText: !_showPass,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _fieldDecoration(
                                  label: "Password",
                                  hint: "Minimum 6 characters",
                                  prefix: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _showPass = !_showPass),
                                    icon: Icon(
                                      _showPass
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.82),
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  final s = (v ?? "");
                                  if (s.isEmpty) return "Password is required";
                                  if (s.length < 6) return "Minimum 6 characters";
                                  return null;
                                },
                              ),

                              // Error
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5A5F)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFFF5A5F)
                                          .withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color:
                                      Colors.redAccent.withOpacity(0.95),
                                      fontSize: 12.2,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // CTA
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signup,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.4),
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add_alt_1_rounded,
                                          size: 18),
                                      SizedBox(width: 10),
                                      Text(
                                        "Create account",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Back to login
                              TextButton(
                                onPressed:
                                _loading ? null : () => Navigator.pop(context),
                                child: Text(
                                  "Already have an account? Sign in",
                                  style: TextStyle(
                                    color: AppColors.accent.withOpacity(0.95),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer microtext
                      Text(
                        "By continuing, you agree to Orion’s terms and privacy policy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.2,
                          color: AppColors.textSecondary.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
