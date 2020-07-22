import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/app_preferences/app_preferences_bloc.dart';

class BlogSettingPage extends StatefulWidget {
  final String blogUrl;
  final String blogAdminUrl;

  const BlogSettingPage({
    Key key,
    @required this.blogUrl,
    @required this.blogAdminUrl,
  }) : super(key: key);

  @override
  _BlogSettingPageState createState() => _BlogSettingPageState();
}

class _BlogSettingPageState extends State<BlogSettingPage> {
  TextEditingController _blogUrlController;
  TextEditingController _blogAdminUrlController;

  @override
  void initState() {
    _blogUrlController = TextEditingController(text: widget.blogUrl);
    _blogAdminUrlController = TextEditingController(text: widget.blogAdminUrl);
    super.initState();
  }

  @override
  void dispose() {
    _blogUrlController.dispose();
    _blogAdminUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置博客网址'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: '博客网址'),
              controller: _blogUrlController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '博客后台网址'),
              controller: _blogAdminUrlController,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              onPressed: () {
                BlocProvider.of<AppPreferencesBloc>(context)
                    .add(AppBlogUrlChanged(
                  blogUrl: _blogUrlController.text,
                  blogAdminUrl: _blogAdminUrlController.text,
                ));
                Navigator.of(context).pop();
              },
              child: Text('提交'),
            ),
          ],
        )),
      ),
    );
  }
}
