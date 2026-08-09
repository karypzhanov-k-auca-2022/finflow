import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_page_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) => AuthPageShell(
    icon: Icons.person_add_alt_1_rounded,
    title: context.l10n.createAccountTitle,
    subtitle: context.l10n.registerSubtitle,
    child: AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.emailAddress,
                hintText: 'name@example.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.enterEmail;
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return context.l10n.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.large),
            TextFormField(
              controller: _passwordController,
              autofillHints: const [AutofillHints.newPassword],
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: context.l10n.password,
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterPassword;
                }
                if (value.length < 6) {
                  return context.l10n.passwordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.large),
            TextFormField(
              controller: _confirmPasswordController,
              autofillHints: const [AutofillHints.newPassword],
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.l10n.repeatPassword,
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  tooltip: context.l10n.repeatPassword,
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.confirmPassword;
                }
                if (value != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.section),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => AuthPrimaryButton(
                loading: state.status == AuthStatus.loading,
                label: context.l10n.registerAction,
                icon: Icons.arrow_forward_rounded,
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(context.l10n.alreadyHaveAccount),
            ),
          ],
        ),
      ),
    ),
  );
}
