import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/app_routes.dart';
import '../theme/cafe_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/auth_underline_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    if (viewModel.isLoading) return;

    FocusScope.of(context).unfocus();

    final success = await viewModel.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Dang nhap that bai')),
      );
    }
  }

  void _showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const LoginHero(),
                const SizedBox(height: 28),
                Text(
                  'LOCAL CAFE\nHUNTER',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 34,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 30),
                AuthUnderlineField(
                  controller: _emailController,
                  hintText: 'Email/Ten dang nhap',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhap email hoac ten dang nhap';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthUnderlineField(
                  controller: _passwordController,
                  hintText: 'Mat khau',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nhap mat khau';
                    }
                    if (value.length < 6) {
                      return 'Mat khau can it nhat 6 ky tu';
                    }
                    return null;
                  },
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: CafeColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                Consumer<AuthViewModel>(
                  builder: (context, vm, _) {
                    return FilledButton.icon(
                      onPressed: vm.isLoading ? null : _handleLogin,
                      icon: vm.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: CafeColors.background,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded, size: 24),
                      label: Text(
                        vm.isLoading ? 'Dang dang nhap...' : 'Dang nhap',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        backgroundColor: CafeColors.dark,
                        foregroundColor: CafeColors.background,
                        shadowColor: CafeColors.dark.withValues(alpha: 0.35),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: CafeColors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CafeColors.dark.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: CafeColors.dark,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Phien ban hien tai dang mo Email/Password truoc de test luong dang nhap on dinh.',
                          style: TextStyle(
                            color: CafeColors.dark,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _showPlaceholderMessage(
                    'Luong quen mat khau chua duoc cau hinh trong project nay.',
                  ),
                  style:
                      TextButton.styleFrom(foregroundColor: CafeColors.muted),
                  child: const Text(
                    'Quen mat khau?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor: CafeColors.dark,
                      decorationThickness: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.register),
                  style: TextButton.styleFrom(foregroundColor: CafeColors.dark),
                  child: const Text(
                    'Chua co tai khoan? Tao ngay',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            child: Transform.rotate(
              angle: 0.18,
              child: Icon(
                Icons.coffee_rounded,
                size: 112,
                color: CafeColors.dark.withValues(alpha: 0.92),
              ),
            ),
          ),
          Positioned(
            left: 56,
            top: 86,
            child: Icon(
              Icons.local_cafe_rounded,
              size: 44,
              color: CafeColors.dark.withValues(alpha: 0.94),
            ),
          ),
          Positioned(
            left: 88,
            top: 96,
            child: Icon(
              Icons.local_cafe_rounded,
              size: 38,
              color: CafeColors.dark.withValues(alpha: 0.88),
            ),
          ),
          Positioned(
            left: 124,
            top: 84,
            child: Icon(
              Icons.local_cafe_rounded,
              size: 42,
              color: CafeColors.dark.withValues(alpha: 0.92),
            ),
          ),
          Positioned(
            right: 64,
            top: 32,
            child: Transform.rotate(
              angle: -0.28,
              child: const Icon(
                Icons.local_cafe_rounded,
                size: 56,
                color: CafeColors.dark,
              ),
            ),
          ),
          Positioned(
            top: 116,
            child: Container(
              width: 196,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: CafeColors.dark, width: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
