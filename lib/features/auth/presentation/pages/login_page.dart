import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        if (state.status == AuthStatus.authenticated) {
          context.go('/dashboard');
        } else if (state.failure != null) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Switcher at Top
                    Center(
                      child: SegmentedButton<AuthMode>(
                        segments: const [
                          ButtonSegment<AuthMode>(
                            value: AuthMode.login,
                            icon: Icon(Icons.login_rounded),
                            label: Text('Вход'),
                          ),
                          ButtonSegment<AuthMode>(
                            value: AuthMode.register,
                            icon: Icon(Icons.person_add_outlined),
                            label: Text('Регистрация'),
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
                    const SizedBox(height: 32),

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
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Hero Icon
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
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
                              const SizedBox(height: 16),

                              // Header Title & Subtitle
                              Text(
                                isRegister
                                    ? 'Создать аккаунт FinFlow'
                                    : 'С возвращением!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isRegister
                                      ? scheme.tertiary
                                      : scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isRegister
                                    ? 'Зарегистрируйтесь для синхронизации бюджета между всеми устройствами'
                                    : 'Войдите в личный кабинет для доступа к своим финансам',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Email Field
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email адрес',
                                  hintText: 'name@example.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите email';
                                  }
                                  if (!value.contains('@') || !value.contains('.')) {
                                    return 'Введите корректный email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
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
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите пароль';
                                  }
                                  if (value.length < 6) {
                                    return 'Пароль должен содержать минимум 6 символов';
                                  }
                                  return null;
                                },
                              ),

                              // Confirm Password Field (Only in Registration Mode)
                              if (isRegister) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: !isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Повторите пароль',
                                    prefixIcon: const Icon(Icons.lock_reset_outlined),
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
                                      return 'Подтвердите пароль';
                                    }
                                    if (value != passwordController.text) {
                                      return 'Пароли не совпадают';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Action Button
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final loading =
                                      state.status == AuthStatus.loading;
                                  return FilledButton.icon(
                                    onPressed: loading ? null : _submit,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      backgroundColor: isRegister
                                          ? scheme.tertiary
                                          : scheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
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
                                          ? 'Загрузка...'
                                          : (isRegister
                                              ? 'Зарегистрироваться'
                                              : 'Войти в аккаунт'),
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
                    const SizedBox(height: 24),

                    // Or Guest Divider & Button
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ИЛИ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().signInAnonymously();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.no_accounts_outlined),
                      label: const Text(
                        'Продолжить как гость (офлайн режим)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
