import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class GroupPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupPanel({@required this.groupProvider});

  @override
  _GroupPanelState createState() => _GroupPanelState();
}

class _GroupPanelState extends State<GroupPanel> {
  TextEditingController name = TextEditingController();
  List<int> usersNumList = [10, 30, 50, 100];
  int usersNum;
  bool qrSecurity;
  bool areaSecurity;

  void _init() async {
    setState(() {
      name.text = widget.groupProvider.group?.name;
      usersNum = widget.groupProvider.group?.usersNum;
      qrSecurity = widget.groupProvider.group?.qrSecurity;
      areaSecurity = widget.groupProvider.group?.areaSecurity;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '会社/組織の設定',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '会社/組織に関する各種設定を行います。セキュリティに関する設定や、時間に関する設定がございます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () async {
                if (!await widget.groupProvider.update(
                  id: widget.groupProvider.group?.id,
                  name: name.text.trim(),
                  usersNum: usersNum,
                  qrSecurity: qrSecurity,
                  areaSecurity: areaSecurity,
                )) {
                  return;
                }
                setState(() {});
              },
              color: Colors.blue,
              iconData: Icons.save,
              label: '設定を保存',
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: ListView(
            children: [
              CustomIconLabel(
                icon: Icon(Icons.store, color: Colors.black54),
                label: '会社情報',
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('会社/組織名', style: TextStyle(fontSize: 14.0)),
                        TextFormField(
                          controller: name,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('人数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: usersNum,
                            onChanged: (value) {
                              setState(() => usersNum = value);
                            },
                            items: usersNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value人以下',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              CustomIconLabel(
                icon: Icon(Icons.security, color: Colors.black54),
                label: '記録セキュリティ',
              ),
              Divider(),
              Row(
                children: [
                  Checkbox(
                    value: qrSecurity,
                    onChanged: (value) {
                      setState(() => qrSecurity = value);
                    },
                    activeColor: Colors.blue,
                  ),
                  Text(
                    'アプリから勤務記録時に、QRコード認証をさせる',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Checkbox(
                    value: areaSecurity,
                    onChanged: (value) {
                      setState(() => areaSecurity = value);
                    },
                    activeColor: Colors.blue,
                  ),
                  Text(
                    'アプリから勤務記録時に、GPSにより記録できる範囲を限定する',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              CustomIconLabel(
                icon: Icon(Icons.access_time, color: Colors.black54),
                label: '時間のまるめ',
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
