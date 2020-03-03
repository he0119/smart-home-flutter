import 'package:flutter/material.dart';
import 'package:smart_home/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("登录")),
      body: LoginForm(),
    );
  }
}
