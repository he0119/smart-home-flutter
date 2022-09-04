import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class LoginPage extends Page {
  const LoginPage()
      : super(
          key: const ValueKey('login'),
          name: '/login',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool canLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            showErrorSnackBar(state.message);
          }
        },
        child: Consumer<SettingsController>(
          builder: (context, settings, child) {
            if (settings.apiUrl == null) {
              canLogin = false;
            }
            return canLogin
                ? LoginForm(onTapBack: () {
                    setState(() {
                      canLogin = false;
                    });
                  })
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
      ),
    );
  }
}

/// 选择服务器网址的界面
class ApiUrlForm extends StatefulWidget {
  final String apiUrl;
  final VoidCallback onTapNext;

  const ApiUrlForm({
    Key? key,
    required this.apiUrl,
    required this.onTapNext,
  }) : super(key: key);

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
                  decoration: const InputDecoration(
                    labelText: '服务器网址',
                  ),
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
                    context
                        .read<GraphQLApiClient>()
                        .initailize(_controller!.text);
                    context
                        .read<SettingsController>()
                        .updateApiUrl(_controller!.text);
                    widget.onTapNext();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('下一步'),
                    Icon(Icons.chevron_right),
                  ],
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
class LoginForm extends StatefulWidget {
  final Function onTapBack;

  const LoginForm({Key? key, required this.onTapBack}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
    void onLoginButtonPressed() {
      BlocProvider.of<AuthenticationBloc>(context).add(
        AuthenticationLogin(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationInProgress) {
          showInfoSnackBar('正在登录...', duration: 1);
        }
      },
      builder: (context, state) {
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    RoundedRaisedButton(
                      onPressed: state is! AuthenticationInProgress
                          ? onLoginButtonPressed
                          : null,
                      child: const Text('登录'),
                    ),
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
