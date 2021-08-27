import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_checkbox_list_tile.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class GroupSecurityPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupSecurityPanel({@required this.groupProvider});

  @override
  _GroupSecurityPanelState createState() => _GroupSecurityPanelState();
}

class _GroupSecurityPanelState extends State<GroupSecurityPanel> {
  GoogleMapController mapController;
  bool qrSecurity;
  bool areaSecurity;
  double areaLat;
  double areaLon;
  double areaRange;

  void _init() async {
    setState(() {
      qrSecurity = widget.groupProvider.group?.qrSecurity;
      areaSecurity = widget.groupProvider.group?.areaSecurity;
      areaLat = widget.groupProvider.group?.areaLat;
      areaLon = widget.groupProvider.group?.areaLon;
      areaRange = widget.groupProvider.group?.areaRange;
    });
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
                        qrSecurity: qrSecurity,
                        areaSecurity: areaSecurity,
                        areaLat: areaLat,
                        areaLon: areaLon,
                        areaRange: areaRange,
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
            setState(() => qrSecurity = value);
          },
          label: 'QRコードで記録制限',
          value: qrSecurity,
        ),
        CustomCheckboxListTile(
          onChanged: (value) {
            setState(() => areaSecurity = value);
          },
          label: '記録可能な範囲を制限',
          value: areaSecurity,
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
                    target: LatLng(areaLat, areaLon),
                    zoom: 17.0,
                  ),
                  circles: Set.from([
                    Circle(
                      circleId: CircleId('area'),
                      center: LatLng(areaLat, areaLon),
                      radius: areaRange,
                      fillColor: Colors.red.withOpacity(0.3),
                      strokeColor: Colors.transparent,
                    ),
                  ]),
                  onTap: (latLng) {
                    setState(() {
                      areaLat = latLng.latitude;
                      areaLon = latLng.longitude;
                    });
                  },
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('半径: $areaRange m'),
                  Expanded(
                    child: Slider(
                      label: '$areaRange',
                      min: 0,
                      max: 500,
                      divisions: 500,
                      value: areaRange,
                      activeColor: Colors.red,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() => areaRange = value);
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
