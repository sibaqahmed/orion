import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.loginWithEmail(
        email: _email.text,
        password: _pass.text,
      );
      // AuthGate will auto-route
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.loginWithGoogle();
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

  Widget _logoHeader() {
    return Column(
      children: [
        // Soft glow behind logo
        Container(
          height: 92,
          width: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accent.withOpacity(0.55),
                AppColors.primary.withOpacity(0.26),
                Colors.transparent,
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withOpacity(0.75),
                border: Border.all(color: AppColors.accent.withOpacity(0.22)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "assets/icons/Orion_logo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Premium ORION text (kept small under logo)
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
              fontSize: 30,
              letterSpacing: 6,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow blobs
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
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface.withOpacity(0.78),
                          AppColors.surface.withOpacity(0.50),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),

                        _logoHeader(),

                        const SizedBox(height: 10),

                        Text(
                          "Welcome back",
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.92),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sign in to continue",
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.9),
                            fontSize: 12.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Email
                        TextField(
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
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextField(
                          controller: _pass,
                          obscureText: !_showPass,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: _fieldDecoration(
                            label: "Password",
                            hint: "Your password",
                            prefix: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _showPass = !_showPass),
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color:
                                AppColors.textSecondary.withOpacity(0.82),
                              ),
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFFF5A5F).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                const Color(0xFFFF5A5F).withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.redAccent.withOpacity(0.95),
                                fontSize: 12.2,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _loginEmail,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, size: 18),
                                SizedBox(width: 10),
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.accent.withOpacity(0.15),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "or",
                                style: TextStyle(
                                  color:
                                  AppColors.textSecondary.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.accent.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Google
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _loginGoogle,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.accent.withOpacity(0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor:
                              AppColors.surface.withOpacity(0.35),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google_logo.png',
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Create account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No account? ",
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _loading
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create one",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
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
