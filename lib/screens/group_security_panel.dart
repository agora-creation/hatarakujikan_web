import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
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
          'アプリから勤務時間を記録する際のセキュリティ設定を行うことができます。',
          style: kAdminSubTitleTextStyle,
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            CustomTextIconButton(
              onPressed: () async {
                if (!await widget.groupProvider.updateSecurity(
                  id: widget.groupProvider.group?.id,
                  qrSecurity: qrSecurity,
                  areaSecurity: areaSecurity,
                  areaLat: areaLat,
                  areaLon: areaLon,
                  areaRange: areaRange,
                )) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('設定の保存が完了しました')),
                );
                widget.groupProvider.reloadGroupModel();
              },
              color: Colors.blue,
              iconData: Icons.save,
              label: '設定を保存',
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      onChanged: (value) {
                        setState(() => qrSecurity = value);
                      },
                      value: qrSecurity,
                      title: Text('勤務時間の記録時にQRコード認証をさせる'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: CheckboxListTile(
                      onChanged: (value) {
                        setState(() => areaSecurity = value);
                      },
                      value: areaSecurity,
                      title: Text('勤務時間の記録時に記録可能な範囲を指定する'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
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
