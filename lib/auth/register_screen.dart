import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/app_routes.dart';
import '../theme/cafe_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'widgets/auth_underline_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    if (viewModel.isLoading) return;

    FocusScope.of(context).unfocus();

    final success = await viewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Dang ky that bai')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_circle_left_outlined,
                      color: CafeColors.dark,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const LoginHero(),
                const SizedBox(height: 22),
                Text(
                  'TAO TAI KHOAN\nLOCAL HUNTER',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 31,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dang ky de luu quan, gom bo suu tap va viet review theo cach cua ban.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 28),
                AuthUnderlineField(
                  controller: _emailController,
                  hintText: 'Email cua ban',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhap email de tao tai khoan';
                    }
                    if (!value.contains('@')) {
                      return 'Email chua dung dinh dang';
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nhap mat khau';
                    }
                    if (value.length < 6) {
                      return 'Mat khau can it nhat 6 ky tu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthUnderlineField(
                  controller: _confirmController,
                  hintText: 'Nhap lai mat khau',
                  icon: Icons.verified_user_outlined,
                  obscureText: _obscureConfirm,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: CafeColors.muted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Xac nhan lai mat khau';
                    }
                    if (value != _passwordController.text) {
                      return 'Mat khau xac nhan chua khop';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 34),
                Consumer<AuthViewModel>(
                  builder: (context, vm, _) {
                    return FilledButton.icon(
                      onPressed: vm.isLoading ? null : _handleRegister,
                      icon: vm.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: CafeColors.background,
                              ),
                            )
                          : const Icon(Icons.how_to_reg_rounded, size: 24),
                      label: Text(
                        vm.isLoading
                            ? 'Dang tao tai khoan...'
                            : 'Tao tai khoan',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        backgroundColor: CafeColors.dark,
                        foregroundColor: CafeColors.background,
                        elevation: 6,
                        shadowColor: CafeColors.dark.withValues(alpha: 0.35),
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
                const SizedBox(height: 18),
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
                      Icon(Icons.info_outline_rounded, color: CafeColors.dark),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sau khi dang ky xong, app se dua ban thang vao Home neu Supabase tra session hop le.',
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
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.login),
                  style: TextButton.styleFrom(foregroundColor: CafeColors.dark),
                  child: const Text(
                    'Da co tai khoan? Quay ve dang nhap',
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
