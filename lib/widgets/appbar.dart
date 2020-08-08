import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/widgets/gravatar.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const MyAppBar({Key key, this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => AppBar(
        title: title != null ? Text(title) : null,
        leading: state is AuthenticationSuccess
            ? IconButton(
                icon: CircleGravatar(email: state.currentUser.email),
                onPressed: () {
                  scaffoldKey.currentState.openDrawer();
                },
              )
            : null,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
