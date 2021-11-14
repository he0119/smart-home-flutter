import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class CommentOrderPage extends StatelessWidget {
  const CommentOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('评论排序')),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: '正序',
                  trailing:
                      trailingWidget(context, false, state.commentDescending),
                  onPressed: (context) {
                    BlocProvider.of<AppPreferencesBloc>(context)
                        .add(const CommentDescendingChanged(descending: false));
                  },
                ),
                SettingsTile(
                  title: '倒序',
                  trailing:
                      trailingWidget(context, true, state.commentDescending),
                  onPressed: (context) {
                    BlocProvider.of<AppPreferencesBloc>(context)
                        .add(const CommentDescendingChanged(descending: true));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(BuildContext context, bool descending, bool current) {
    return (descending == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
