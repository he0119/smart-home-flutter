import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
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
      body: Builder(
        builder: (context) {
          final settings = ref.watch(settingsProvider);
          return canLogin
              ? LoginForm(
                  onTapBack: () {
                    setState(() {
                      canLogin = false;
                    });
                  },
                )
              : ApiUrlForm(
                  apiUrl: settings.apiUrl,
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
class ApiUrlForm extends ConsumerStatefulWidget {
  final String apiUrl;
  final VoidCallback onTapNext;

  const ApiUrlForm({super.key, required this.apiUrl, required this.onTapNext});

  @override
  ConsumerState<ApiUrlForm> createState() => _ApiUrlFormState();
}

class _ApiUrlFormState extends ConsumerState<ApiUrlForm> {
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
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: AppSpacing.lg,
                children: <Widget>[
                  Image.asset(
                    'assets/icon/icon.webp',
                    width: 100.0,
                    height: 100.0,
                    semanticLabel: 'icon',
                  ),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: '服务器网址',
                      helperText: '修改后需要重新登录',
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      final text = value ?? '';
                      if (text.startsWith(RegExp(r'^https?://'))) {
                        return null;
                      }
                      return '网址必须以 http:// 或 https:// 开头';
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(graphQLApiClientProvider)
                              .initialize(_controller!.text);
                          ref
                              .read(settingsProvider.notifier)
                              .updateApiUrl(_controller!.text);
                          widget.onTapNext();
                        }
                      },
                      child: const Text('下一步'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 输入用户名密码的登录界面
class LoginForm extends ConsumerStatefulWidget {
  final VoidCallback onTapBack;

  const LoginForm({super.key, required this.onTapBack});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

enum LoginMethod { password, oidc }

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
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
    final settings = ref.watch(settingsProvider);
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  spacing: AppSpacing.md,
                  children: <Widget>[
                    Image.asset(
                      'assets/icon/icon.webp',
                      width: 100.0,
                      height: 100.0,
                      semanticLabel: 'icon',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<LoginMethod>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<LoginMethod>>[
                          ButtonSegment(
                            value: LoginMethod.password,
                            label: Text('密码登录', softWrap: false, maxLines: 1),
                          ),
                          ButtonSegment(
                            value: LoginMethod.oidc,
                            label: Text('单点登录', softWrap: false, maxLines: 1),
                          ),
                        ],
                        selected: <LoginMethod>{loginMethod},
                        onSelectionChanged: (Set<LoginMethod> newSelection) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateLoginMethod(
                                newSelection.first == LoginMethod.oidc
                                    ? 'oidc'
                                    : 'password',
                              );
                        },
                      ),
                    ),
                    if (loginMethod == LoginMethod.password) ...<Widget>[
                      TextFormField(
                        enableSuggestions: false,
                        decoration: const InputDecoration(labelText: '用户名'),
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.username],
                        validator: (value) =>
                            (value == null || value.isEmpty) ? '请输入用户名' : null,
                      ),
                      TextFormField(
                        enableSuggestions: false,
                        decoration: const InputDecoration(labelText: '密码'),
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: (value) =>
                            (value == null || value.isEmpty) ? '请输入密码' : null,
                        onFieldSubmitted: (_) {
                          if (_formKey.currentState!.validate()) {
                            onLoginButtonPressed();
                          }
                        },
                      ),
                    ] else
                      Text(
                        '点击下方按钮将进行单点登录',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  onLoginButtonPressed();
                                }
                              },
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('登录'),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onTapBack,
                      child: const Text('返回'),
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

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
/// fakeAuth 换掉真的登录状态，否则预览一启动就去请求后端。
@AppPreview(name: 'LoginForm', group: previewGroupAuth, size: Size(420, 560))
Widget loginFormPreview() => PreviewFrame(
  width: 420,
  padding: EdgeInsets.zero,
  child: PreviewProviders(
    settings: previewSettings(),
    fakeAuth: true,
    child: LoginForm(onTapBack: () {}),
  ),
);

@AppPreview(name: 'ApiUrlForm', group: previewGroupAuth, size: Size(420, 520))
Widget apiUrlFormPreview() => PreviewFrame(
  width: 420,
  padding: EdgeInsets.zero,
  child: PreviewProviders(
    settings: previewSettings(),
    fakeAuth: true,
    child: ApiUrlForm(apiUrl: 'https://smart.example.com', onTapNext: () {}),
  ),
);
