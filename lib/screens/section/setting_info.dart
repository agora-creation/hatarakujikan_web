import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold2.dart';
import 'package:hatarakujikan_web/widgets/custom_label_column.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:provider/provider.dart';

class SectionSettingInfoScreen extends StatelessWidget {
  static const String id = 'section_setting_info';

  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);

    return CustomAdminScaffold2(
      sectionProvider: sectionProvider,
      selectedRoute: id,
      body: SectionSettingInfoPanel(sectionProvider: sectionProvider),
    );
  }
}

class SectionSettingInfoPanel extends StatefulWidget {
  final SectionProvider sectionProvider;

  SectionSettingInfoPanel({@required this.sectionProvider});

  @override
  _SectionSettingInfoPanelState createState() =>
      _SectionSettingInfoPanelState();
}

class _SectionSettingInfoPanelState extends State<SectionSettingInfoPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本情報',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '部署/事業所の基本情報です。以下の「QRコード出力」で会社/組織IDが入ったQRコードをプリントして、スタッフの見える位置に貼ってください。',
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
                    await PdfApi.qrcode(group: widget.sectionProvider.group);
                  },
                  color: Colors.redAccent,
                  iconData: Icons.qr_code,
                  label: 'QRコード出力',
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
              CustomLabelColumn(
                label: '部署/事業所名',
                child: Text('${widget.sectionProvider.section?.name}'),
              ),
              Divider(),
              SizedBox(height: 8.0),
              CustomLabelColumn(
                label: '管理者',
                child: Text('${widget.sectionProvider.adminUser?.name}'),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
