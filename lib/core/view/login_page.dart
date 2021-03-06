import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/app/app_config.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class LoginPage extends Page {
  LoginPage()
      : super(
          key: const ValueKey('login'),
          name: '/login',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool canLogin = true;

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.of(context);
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
          builder: (context, state) {
            if (state.apiUrl == null) {
              canLogin = false;
            }
            return canLogin
                ? LoginForm(onTapBack: () {
                    setState(() {
                      canLogin = false;
                    });
                  })
                : ApiUrlForm(
                    apiUrl: state.apiUrl ?? appConfig.apiUrl,
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
  final Function onTapNext;

  ApiUrlForm({
    Key? key,
    required this.apiUrl,
    required this.onTapNext,
  }) : super(key: key);

  @override
  _ApiUrlFormState createState() => _ApiUrlFormState();
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
                    BlocProvider.of<AppPreferencesBloc>(context).add(
                      AppApiUrlChanged(apiUrl: _controller!.text),
                    );
                    widget.onTapNext();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('下一步'),
                    const Icon(Icons.chevron_right),
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

  LoginForm({required this.onTapBack});

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
    void _onLoginButtonPressed() {
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
                        autofillHints: <String>[AutofillHints.username],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: TextFormField(
                        enableSuggestions: false,
                        decoration: const InputDecoration(labelText: '密码'),
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: <String>[AutofillHints.password],
                      ),
                    ),
                    RoundedRaisedButton(
                      onPressed: state is! AuthenticationInProgress
                          ? _onLoginButtonPressed
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
