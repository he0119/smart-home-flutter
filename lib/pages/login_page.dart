import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool canLogin = true;

  @override
  Widget build(BuildContext context) {
    AppConfig appConfig = AppConfig.of(context);
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            showErrorSnackBar(context, state.message);
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
    Key key,
    @required this.apiUrl,
    @required this.onTapNext,
  }) : super(key: key);

  @override
  _ApiUrlFormState createState() => _ApiUrlFormState();
}

class _ApiUrlFormState extends State<ApiUrlForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.apiUrl);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/icon.png',
            width: 100.0,
            height: 100.0,
            semanticLabel: 'icon',
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '服务器网址',
              ),
              controller: _controller,
              validator: (value) {
                if (value.startsWith(RegExp(r'^https?://'))) {
                  return null;
                }
                return '网址必须为 http:// 或 https:// 开头，请输入正确的网址';
              },
              autovalidate: true,
            ),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                BlocProvider.of<AppPreferencesBloc>(context).add(
                  AppApiUrlChanged(apiUrl: _controller.text),
                );
                widget.onTapNext();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('下一步'),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 输入用户名密码的登录界面
class LoginForm extends StatefulWidget {
  final Function onTapBack;

  LoginForm({@required this.onTapBack});

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
    _onLoginButtonPressed() {
      BlocProvider.of<AuthenticationBloc>(context).add(
        AuthenticationLogin(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              width: 100.0,
              height: 100.0,
              semanticLabel: 'icon',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                child: AutofillGroup(
                  child: Column(
                    children: [
                      TextFormField(
                        enableSuggestions: false,
                        decoration: InputDecoration(labelText: '用户名'),
                        controller: _usernameController,
                        autofillHints: <String>[AutofillHints.username],
                      ),
                      TextFormField(
                        enableSuggestions: false,
                        decoration: InputDecoration(labelText: '密码'),
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: <String>[AutofillHints.password],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              onPressed: state is! AuthenticationInProgress
                  ? _onLoginButtonPressed
                  : null,
              child: Text('登录'),
            ),
            FlatButton(
              onPressed: widget.onTapBack,
              child: Text('返回'),
            ),
            Container(
              child: state is AuthenticationInProgress
                  ? CircularProgressIndicator()
                  : null,
            ),
          ],
        );
      },
    );
  }
}
