import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/presentation/authen/authen_cubit.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

class AuthenPage extends StatefulWidget {
  final Widget child;
  const AuthenPage({super.key, required this.child});

  @override
  AuthenPageState createState() => AuthenPageState();
}

class AuthenPageState extends State<AuthenPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final showPasswordController = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final authenCubit = BlocProvider.of<AuthenCubit>(context);
    final state = authenCubit.state;
    if (!state.isInitialized || state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isAuthenticated) {
      return widget.child;
    }
    return ValueListenableBuilder(
      valueListenable: showPasswordController,
      builder: (context, showPassword, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxWidth: context.w(0.6).clamp(0, 600),
              maxHeight: context.h(0.5).clamp(0, 600),
            ),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colorScheme.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WireTap',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.headlineLarge?.copyWith(
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: !showPassword,
                  obscuringCharacter: '*',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox.adaptive(
                      value: showPassword,
                      onChanged: (value) {
                        showPasswordController.value = value ?? true;
                      },
                    ),
                    Text('Show password'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();
                    if (username.isEmpty || password.isEmpty) {
                      UiRepo().showSnackBar(context, 'Username and password cannot be empty');
                      return;
                    }
                    authenCubit.login(username, password);
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
