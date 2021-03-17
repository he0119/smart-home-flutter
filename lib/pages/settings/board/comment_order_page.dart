import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/blocs/core/blocs.dart';

class CommentOrderPage extends StatelessWidget {
  const CommentOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text('评论排序')),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: '正序',
                  trailing: trailingWidget(false, state.commentDescending),
                  onTap: () {
                    BlocProvider.of<AppPreferencesBloc>(context)
                        .add(CommentDescendingChanged(descending: false));
                  },
                ),
                SettingsTile(
                  title: '倒序',
                  trailing: trailingWidget(true, state.commentDescending),
                  onTap: () {
                    BlocProvider.of<AppPreferencesBloc>(context)
                        .add(CommentDescendingChanged(descending: true));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(bool descending, bool current) {
    return (descending == current)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }
}
