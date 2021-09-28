import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';
import 'package:provider/provider.dart';

class SettingSecurityScreen extends StatelessWidget {
  static const String id = 'group_security';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: SettingSecurityPanel(groupProvider: groupProvider),
    );
  }
}

class SettingSecurityPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  SettingSecurityPanel({@required this.groupProvider});

  @override
  _SettingSecurityPanelState createState() => _SettingSecurityPanelState();
}

class _SettingSecurityPanelState extends State<SettingSecurityPanel> {
  GoogleMapController mapController;
  bool _qrSecurity;
  bool _areaSecurity;
  double _areaLat;
  double _areaLon;
  double _areaRange;

  void _init() async {
    _qrSecurity = widget.groupProvider.group?.qrSecurity;
    _areaSecurity = widget.groupProvider.group?.areaSecurity;
    _areaLat = widget.groupProvider.group?.areaLat;
    _areaLon = widget.groupProvider.group?.areaLon;
    _areaRange = widget.groupProvider.group?.areaRange;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
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
          'セキュリティ設定',
          style: kAdminTitleTextStyle,
        ),
        Text(
          'スマートフォンアプリから勤務時間を記録する際、不明な記録が残らないようにセキュリティ設定を行うことができます。',
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
                    await PdfApi.qrcode(group: widget.groupProvider.group);
                  },
                  color: Colors.redAccent,
                  iconData: Icons.qr_code,
                  label: 'QRコード出力',
                ),
                SizedBox(width: 4.0),
                CustomTextIconButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => ConfirmDialog(
                        groupProvider: widget.groupProvider,
                        qrSecurity: _qrSecurity,
                        areaSecurity: _areaSecurity,
                        areaLat: _areaLat,
                        areaLon: _areaLon,
                        areaRange: _areaRange,
                      ),
                    );
                  },
                  color: Colors.blue,
                  iconData: Icons.save,
                  label: '設定を保存',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        CustomCheckboxListTile(
          onChanged: (value) {
            setState(() => _qrSecurity = value);
          },
          label: 'QRコードで記録制限',
          value: _qrSecurity,
        ),
        CustomCheckboxListTile(
          onChanged: (value) {
            setState(() => _areaSecurity = value);
          },
          label: '記録可能な範囲を制限',
          value: _areaSecurity,
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_areaLat, _areaLon),
                    zoom: 17.0,
                  ),
                  circles: Set.from([
                    Circle(
                      circleId: CircleId('area'),
                      center: LatLng(_areaLat, _areaLon),
                      radius: _areaRange,
                      fillColor: Colors.red.withOpacity(0.3),
                      strokeColor: Colors.transparent,
                    ),
                  ]),
                  onTap: (latLng) {
                    setState(() {
                      _areaLat = latLng.latitude;
                      _areaLon = latLng.longitude;
                    });
                  },
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('半径: $_areaRange m'),
                  Expanded(
                    child: Slider(
                      label: '$_areaRange',
                      min: 0,
                      max: 500,
                      divisions: 500,
                      value: _areaRange,
                      activeColor: Colors.red,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() => _areaRange = value);
                      },
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

class ConfirmDialog extends StatelessWidget {
  final GroupProvider groupProvider;
  final bool qrSecurity;
  final bool areaSecurity;
  final double areaLat;
  final double areaLon;
  final double areaRange;

  ConfirmDialog({
    @required this.groupProvider,
    @required this.qrSecurity,
    @required this.areaSecurity,
    @required this.areaLat,
    @required this.areaLon,
    @required this.areaRange,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Text(
            '設定内容を保存します。よろしいですか？',
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.grey,
                label: 'キャンセル',
              ),
              CustomTextButton(
                onPressed: () async {
                  if (!await groupProvider.updateSecurity(
                    id: groupProvider.group?.id,
                    qrSecurity: qrSecurity,
                    areaSecurity: areaSecurity,
                    areaLat: areaLat,
                    areaLon: areaLon,
                    areaRange: areaRange,
                  )) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('セキュリティ設定を保存しました')),
                  );
                  groupProvider.reloadGroupModel();
                  Navigator.pop(context);
                },
                color: Colors.blue,
                label: 'はい',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
