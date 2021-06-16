import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class GroupPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupPanel({@required this.groupProvider});

  @override
  _GroupPanelState createState() => _GroupPanelState();
}

class _GroupPanelState extends State<GroupPanel> {
  List<int> usersNumList = [10, 30, 50, 100];

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
              onPressed: () {},
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
                  TextFormField(
                    controller: null,
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                      labelText: '会社/組織名',
                    ),
                  ),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: 10,
                    onChanged: (value) {},
                    items: usersNumList.map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value人以下'),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              CustomIconLabel(
                icon: Icon(Icons.group, color: Colors.black54),
                label: '人数 (○人以下)',
              ),
              DropdownButton<int>(
                isExpanded: true,
                value: 10,
                onChanged: (value) {},
                items: usersNumList.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value人以下'),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              CustomIconLabel(
                icon: Icon(Icons.security, color: Colors.black54),
                label: '記録セキュリティ',
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
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
                    value: false,
                    onChanged: (value) {},
                    activeColor: Colors.blue,
                  ),
                  Text(
                    'アプリから勤務記録時に、GPSにより記録できる範囲を限定する',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              CustomIconLabel(
                icon: Icon(Icons.access_time, color: Colors.black54),
                label: '時間のまるめ',
              ),
              SizedBox(height: 8.0),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '出勤時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '退勤時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '休憩開始時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '休憩終了時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '勤務時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
              CustomTextFormField(
                controller: null,
                obscureText: false,
                textInputType: TextInputType.name,
                maxLines: 1,
                label: '法定時間',
                color: Colors.black54,
                prefix: Icons.access_time,
                suffix: null,
                onTap: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
