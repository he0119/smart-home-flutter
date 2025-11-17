import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class LoginPage extends Page {
  const LoginPage() : super(key: const ValueKey('login'), name: '/login');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const LoginScreen(),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool canLogin = true;

  @override
  Widget build(BuildContext context) {
    // 监听认证错误
    ref.listen<AuthState>(authenticationProvider, (previous, next) {
      if (next.errorMessage != null) {
        showErrorSnackBar(next.errorMessage!);
        ref.read(authenticationProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: provider.Consumer<SettingsController>(
        builder: (context, settings, child) {
          if (settings.apiUrl == null) {
            canLogin = false;
          }
          return canLogin
              ? LoginForm(
                  onTapBack: () {
                    setState(() {
                      canLogin = false;
                    });
                  },
                )
              : ApiUrlForm(
                  apiUrl: settings.apiUrl ?? settings.appConfig.defaultApiUrl,
                  onTapNext: () {
                    setState(() {
                      canLogin = true;
                    });
                  },
                );
        },
      ),
    );
  }
}

/// 选择服务器网址的界面
class ApiUrlForm extends StatefulWidget {
  final String apiUrl;
  final VoidCallback onTapNext;

  const ApiUrlForm({super.key, required this.apiUrl, required this.onTapNext});

  @override
  State<ApiUrlForm> createState() => _ApiUrlFormState();
}

class _ApiUrlFormState extends State<ApiUrlForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.apiUrl);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/icon/icon.webp',
                width: 100.0,
                height: 100.0,
                semanticLabel: 'icon',
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: '服务器网址'),
                  controller: _controller,
                  validator: (value) {
                    if (value!.startsWith(RegExp(r'^https?://'))) {
                      return null;
                    }
                    return '网址必须为 http:// 或 https:// 开头，请输入正确的网址';
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              RoundedRaisedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<GraphQLApiClient>().initailize(
                      _controller!.text,
                    );
                    context.read<SettingsController>().updateApiUrl(
                      _controller!.text,
                    );
                    widget.onTapNext();
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('下一步'), Icon(Icons.chevron_right)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 输入用户名密码的登录界面
class LoginForm extends ConsumerStatefulWidget {
  final Function onTapBack;

  const LoginForm({super.key, required this.onTapBack});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

enum LoginMethod { password, oidc }

class _LoginFormState extends ConsumerState<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final loginMethod = settings.loginMethod == 'oidc'
        ? LoginMethod.oidc
        : LoginMethod.password;

    void onLoginButtonPressed() {
      if (loginMethod == LoginMethod.password) {
        ref
            .read(authenticationProvider.notifier)
            .login(_usernameController.text, _passwordController.text);
      } else {
        ref.read(authenticationProvider.notifier).oidcLogin();
      }
    }

    // 监听登录状态
    ref.listen<AuthState>(authenticationProvider, (previous, next) {
      if (next.isLoading && !(previous?.isLoading ?? false)) {
        showInfoSnackBar('正在登录...', duration: 1);
      }
    });

    final authState = ref.watch(authenticationProvider);
    return Builder(
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Form(
              child: AutofillGroup(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/icon.webp',
                      width: 100.0,
                      height: 100.0,
                      semanticLabel: 'icon',
                    ),
                    const SizedBox(height: 20),
                    // 登录方式选择
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SegmentedButton<LoginMethod>(
                        segments: const [
                          ButtonSegment(
                            value: LoginMethod.password,
                            label: Text('密码登录'),
                            icon: Icon(Icons.password),
                          ),
                          ButtonSegment(
                            value: LoginMethod.oidc,
                            label: Text('单点登录'),
                            icon: Icon(Icons.login),
                          ),
                        ],
                        selected: {loginMethod},
                        onSelectionChanged: (Set<LoginMethod> newSelection) {
                          settings.updateLoginMethod(
                            newSelection.first == LoginMethod.oidc
                                ? 'oidc'
                                : 'password',
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 用户名输入框（两种登录方式都需要）
                    if (loginMethod == LoginMethod.password) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          enableSuggestions: false,
                          decoration: const InputDecoration(labelText: '用户名'),
                          controller: _usernameController,
                          autofillHints: const <String>[AutofillHints.username],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: TextFormField(
                          enableSuggestions: false,
                          decoration: const InputDecoration(labelText: '密码'),
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const <String>[AutofillHints.password],
                        ),
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Text(
                          '点击下方按钮将进行单点登录',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: FilledButton(
                          onPressed: !authState.isLoading
                              ? onLoginButtonPressed
                              : null,
                          child: const Text('登录'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onTapBack as void Function()?,
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
