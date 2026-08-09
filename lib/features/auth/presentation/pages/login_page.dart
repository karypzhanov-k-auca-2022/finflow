import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../bloc/auth_cubit.dart';

enum AuthMode { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  AuthMode currentMode = AuthMode.login;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (currentMode == AuthMode.register) {
      cubit.signUpWithEmail(email, password);
    } else {
      cubit.signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRegister = currentMode == AuthMode.register;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: scheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.section,
                vertical: AppSpacing.large,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mode Switcher at Top
                      Center(
                        child: SegmentedButton<AuthMode>(
                          segments: [
                            ButtonSegment<AuthMode>(
                              value: AuthMode.login,
                              icon: const Icon(Icons.login_rounded),
                              label: Text(context.l10n.login),
                            ),
                            ButtonSegment<AuthMode>(
                              value: AuthMode.register,
                              icon: const Icon(Icons.person_add_outlined),
                              label: Text(context.l10n.registration),
                            ),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (selection) {
                            setState(() {
                              currentMode = selection.first;
                              formKey.currentState?.reset();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.huge),

                      // Animated Card Container for Mode Distinctness
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          key: ValueKey(currentMode),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: isRegister
                                  ? scheme.tertiary.withValues(alpha: 0.3)
                                  : scheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.section),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Hero Icon
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.large,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isRegister
                                          ? scheme.tertiaryContainer
                                          : scheme.primaryContainer,
                                    ),
                                    child: Icon(
                                      isRegister
                                          ? Icons.person_add_alt_1_rounded
                                          : Icons.lock_person_rounded,
                                      size: 48,
                                      color: isRegister
                                          ? scheme.onTertiaryContainer
                                          : scheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.large),

                                // Header Title & Subtitle
                                Text(
                                  isRegister
                                      ? context.l10n.createAccountTitle
                                      : context.l10n.welcomeBack,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isRegister
                                            ? scheme.tertiary
                                            : scheme.primary,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.compact),
                                Text(
                                  isRegister
                                      ? context.l10n.registerSubtitle
                                      : context.l10n.loginSubtitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sectionLarge),

                                // Email Field
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.emailAddress,
                                    hintText: 'name@example.com',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return context.l10n.enterEmail;
                                    }
                                    if (!value.contains('@') ||
                                        !value.contains('.')) {
                                      return context.l10n.invalidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.large),

                                // Password Field
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: !isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.password,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPasswordVisible =
                                              !isPasswordVisible;
                                        });
                                      },
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

                                // Confirm Password Field (Only in Registration Mode)
                                if (isRegister) ...[
                                  const SizedBox(height: AppSpacing.large),
                                  TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: !isConfirmPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: context.l10n.repeatPassword,
                                      prefixIcon: const Icon(
                                        Icons.lock_reset_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isConfirmPasswordVisible =
                                                !isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return context.l10n.confirmPassword;
                                      }
                                      if (value != passwordController.text) {
                                        return context.l10n.passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                const SizedBox(height: AppSpacing.section),

                                // Action Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final loading =
                                        state.status == AuthStatus.loading;
                                    return FilledButton.icon(
                                      onPressed: loading ? null : _submit,
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.mediumLarge,
                                        ),
                                        backgroundColor: isRegister
                                            ? scheme.tertiary
                                            : scheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: loading
                                          ? const SizedBox.square(
                                              dimension: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              isRegister
                                                  ? Icons.person_add_rounded
                                                  : Icons.login_rounded,
                                            ),
                                      label: Text(
                                        loading
                                            ? context.l10n.loading
                                            : (isRegister
                                                  ? context.l10n.registerAction
                                                  : context.l10n.signInAction),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),

                      // Or Guest Divider & Button
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.large,
                            ),
                            child: Text(
                              context.l10n.or,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),

                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) => OutlinedButton.icon(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : () => context
                                    .read<AuthCubit>()
                                    .signInAnonymously(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.medium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.no_accounts_outlined),
                          label: Text(
                            context.l10n.continueAsGuestOffline,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
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
