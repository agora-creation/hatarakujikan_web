import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/models/section.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/screens/section/work.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';

class SectionSelectScreen extends StatefulWidget {
  final SectionProvider sectionProvider;

  SectionSelectScreen({@required this.sectionProvider});

  @override
  _SectionSelectScreenState createState() => _SectionSelectScreenState();
}

class _SectionSelectScreenState extends State<SectionSelectScreen> {
  bool _isLoading = false;

  void _init() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    if (widget.sectionProvider.sections.length == 1) {
      await widget.sectionProvider.setSection(
        widget.sectionProvider.sections.first,
      );
      setState(() => _isLoading = false);
      Navigator.of(context, rootNavigator: true).pop();
      changeScreen(context, SectionWorkScreen());
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading(color: Colors.orange)
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.orange,
              elevation: 0.0,
              centerTitle: true,
              title: Text('部署/事業所の選択', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  onPressed: () {
                    widget.sectionProvider.signOut();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            body: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: widget.sectionProvider.sections.length,
              itemBuilder: (_, index) {
                SectionModel _section = widget.sectionProvider.sections[index];
                return Container(
                  decoration: kBottomBorderDecoration,
                  child: ListTile(
                    onTap: () async {
                      setState(() => _isLoading = true);
                      await widget.sectionProvider.setSection(_section);
                      setState(() => _isLoading = false);
                      Navigator.of(context, rootNavigator: true).pop();
                      changeScreen(context, SectionWorkScreen());
                    },
                    title: Text(
                        '${widget.sectionProvider.group?.name} (${_section.name})'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
  }
}
