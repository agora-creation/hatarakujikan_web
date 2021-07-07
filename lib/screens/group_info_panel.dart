import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class GroupInfoPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupInfoPanel({@required this.groupProvider});

  @override
  _GroupInfoPanelState createState() => _GroupInfoPanelState();
}

class _GroupInfoPanelState extends State<GroupInfoPanel> {
  TextEditingController name = TextEditingController();
  TextEditingController positions = TextEditingController();

  void _init() async {
    setState(() {
      name.text = widget.groupProvider.group?.name;
      String tmp = '';
      for (String _position in widget.groupProvider.group?.positions) {
        if (tmp != '') tmp += ',';
        tmp += _position;
      }
      positions.text = tmp;
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
          '基本情報の変更',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '会社/組織の基本情報を変更できます。また、以下の「QRコード出力」で会社/組織IDが入ったQRコードをプリントして、スタッフの見える位置に貼ってください。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Row(
              children: [
                CustomTextIconButton(
                  onPressed: () async {
                    await qrPdf(group: widget.groupProvider.group);
                  },
                  color: Colors.redAccent,
                  iconData: Icons.qr_code,
                  label: 'QRコード出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () async {
                    if (!await widget.groupProvider.updateInfo(
                      id: widget.groupProvider.group?.id,
                      name: name.text.trim(),
                      positions: positions.text.trim(),
                    )) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('変更の保存が完了しました')),
                    );
                    widget.groupProvider.reloadGroupModel();
                  },
                  color: Colors.blue,
                  iconData: Icons.save,
                  label: '変更を保存',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('人数', style: TextStyle(fontSize: 14.0)),
                  Text(
                    '${widget.groupProvider.group?.usersNum} 人まで',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Column(
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
              SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '雇用形態 (カンマ区切りで入力してください)',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  TextFormField(
                    controller: positions,
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
            ],
          ),
        ),
      ],
    );
  }
}
