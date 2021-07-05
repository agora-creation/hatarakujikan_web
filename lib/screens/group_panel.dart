import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hatarakujikan_web/helpers/pdf_api.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/widgets/custom_icon_label.dart';
import 'package:hatarakujikan_web/widgets/custom_link_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_icon_button.dart';

class GroupPanel extends StatefulWidget {
  final GroupProvider groupProvider;

  GroupPanel({@required this.groupProvider});

  @override
  _GroupPanelState createState() => _GroupPanelState();
}

class _GroupPanelState extends State<GroupPanel> {
  TextEditingController name = TextEditingController();
  TextEditingController usersNum = TextEditingController();
  TextEditingController positions = TextEditingController();
  bool qrSecurity;
  bool areaSecurity;
  double areaLat;
  double areaLon;
  double areaRange;
  List<String> roundTypeList = ['切捨', '切上'];
  List<int> roundNumList = [1, 5, 10, 15, 30];
  String roundStartType;
  int roundStartNum;
  String roundEndType;
  int roundEndNum;
  String roundBreakStartType;
  int roundBreakStartNum;
  String roundBreakEndType;
  int roundBreakEndNum;
  String roundWorkType;
  int roundWorkNum;
  List<int> legalList = [8];
  int legal;
  String nightStart;
  String nightEnd;
  GoogleMapController mapController;

  void _init() async {
    setState(() {
      name.text = widget.groupProvider.group?.name;
      usersNum.text = '${widget.groupProvider.group?.usersNum}人まで';
      String tmp = '';
      for (String _position in widget.groupProvider.group?.positions) {
        if (tmp != '') tmp += ',';
        tmp += _position;
      }
      positions.text = tmp;
      qrSecurity = widget.groupProvider.group?.qrSecurity;
      areaSecurity = widget.groupProvider.group?.areaSecurity;
      areaLat = widget.groupProvider.group?.areaLat;
      areaLon = widget.groupProvider.group?.areaLon;
      areaRange = widget.groupProvider.group?.areaRange;
      roundStartType = widget.groupProvider.group?.roundStartType;
      roundStartNum = widget.groupProvider.group?.roundStartNum;
      roundEndType = widget.groupProvider.group?.roundEndType;
      roundEndNum = widget.groupProvider.group?.roundEndNum;
      roundBreakStartType = widget.groupProvider.group?.roundBreakStartType;
      roundBreakStartNum = widget.groupProvider.group?.roundBreakStartNum;
      roundBreakEndType = widget.groupProvider.group?.roundBreakEndType;
      roundBreakEndNum = widget.groupProvider.group?.roundBreakEndNum;
      roundWorkType = widget.groupProvider.group?.roundWorkType;
      roundWorkNum = widget.groupProvider.group?.roundWorkNum;
      legal = widget.groupProvider.group?.legal;
      nightStart = widget.groupProvider.group?.nightStart;
      nightEnd = widget.groupProvider.group?.nightEnd;
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
          '会社/組織の設定',
          style: kAdminTitleTextStyle,
        ),
        Text(
          '会社/組織に関する各種設定を行います。セキュリティに関する設定や、時間に関する設定ができます。',
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
                    if (!await widget.groupProvider.update(
                      id: widget.groupProvider.group?.id,
                      name: name.text.trim(),
                      positions: positions.text.trim(),
                      qrSecurity: qrSecurity,
                      areaSecurity: areaSecurity,
                      areaLat: areaLat,
                      areaLon: areaLon,
                      areaRange: areaRange,
                      roundStartType: roundStartType,
                      roundStartNum: roundStartNum,
                      roundEndType: roundEndType,
                      roundEndNum: roundEndNum,
                      roundBreakStartType: roundBreakStartType,
                      roundBreakStartNum: roundBreakStartNum,
                      roundBreakEndType: roundBreakEndType,
                      roundBreakEndNum: roundBreakEndNum,
                      roundWorkType: roundWorkType,
                      roundWorkNum: roundWorkNum,
                      legal: legal,
                      nightStart: nightStart,
                      nightEnd: nightEnd,
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
          ],
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: ListView(
            children: [
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.store, color: Colors.black54),
                  label: '会社情報',
                ),
              ),
              SizedBox(height: 8.0),
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
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('人数制限', style: TextStyle(fontSize: 14.0)),
                        TextFormField(
                          readOnly: true,
                          controller: usersNum,
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
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.security, color: Colors.black54),
                  label: '記録セキュリティ',
                ),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 4.0),
              Container(
                height: 350.0,
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
              SizedBox(height: 4.0),
              Center(child: Text('指定範囲の半径: $areaRange m')),
              Slider(
                label: '$areaRange',
                min: 0,
                max: 500,
                divisions: 500,
                value: areaRange,
                activeColor: Colors.red,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() => areaRange = value);
                },
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '時間のまるめ',
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('出勤時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: roundStartType,
                            onChanged: (value) {
                              setState(() => roundStartType = value);
                            },
                            items: roundTypeList.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
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
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: roundStartNum,
                            onChanged: (value) {
                              setState(() => roundStartNum = value);
                            },
                            items: roundNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value分',
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
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('退勤時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: roundEndType,
                            onChanged: (value) {
                              setState(() => roundEndType = value);
                            },
                            items: roundTypeList.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
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
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: roundEndNum,
                            onChanged: (value) {
                              setState(() => roundEndNum = value);
                            },
                            items: roundNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value分',
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
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('休憩開始時間'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: roundBreakStartType,
                            onChanged: (value) {
                              setState(() => roundBreakStartType = value);
                            },
                            items: roundTypeList.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
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
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: roundBreakStartNum,
                            onChanged: (value) {
                              setState(() => roundBreakStartNum = value);
                            },
                            items: roundNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value分',
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
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('休憩終了時間'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: roundBreakEndType,
                            onChanged: (value) {
                              setState(() => roundBreakEndType = value);
                            },
                            items: roundTypeList.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
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
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: roundBreakEndNum,
                            onChanged: (value) {
                              setState(() => roundBreakEndNum = value);
                            },
                            items: roundNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value分',
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
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('勤務時間　　'),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ方', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: roundWorkType,
                            onChanged: (value) {
                              setState(() => roundWorkType = value);
                            },
                            items: roundTypeList.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
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
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('まるめ分数', style: TextStyle(fontSize: 14.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: roundWorkNum,
                            onChanged: (value) {
                              setState(() => roundWorkNum = value);
                            },
                            items: roundNumList.map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  '$value分',
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
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '法定時間',
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: legal,
                    onChanged: (value) {
                      setState(() => legal = value);
                    },
                    items: legalList.map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value時間',
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
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.access_time, color: Colors.black54),
                  label: '深夜時間帯',
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      List<String> _hm = nightStart.split(':');
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hm.first),
                          minute: int.parse(_hm.last),
                        ),
                      );
                      if (_selected != null) {
                        String _time = '${_selected.format(context)}';
                        setState(() => nightStart = _time);
                      }
                    },
                    icon: Icon(
                      Icons.access_time,
                      color: Colors.black54,
                      size: 16.0,
                    ),
                    label: Text(
                      nightStart,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.black38, width: 1),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text('〜'),
                  SizedBox(width: 8.0),
                  TextButton.icon(
                    onPressed: () async {
                      List<String> _hm = nightEnd.split(':');
                      TimeOfDay _selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(_hm.first),
                          minute: int.parse(_hm.last),
                        ),
                      );
                      if (_selected != null) {
                        String _time = '${_selected.format(context)}';
                        setState(() => nightEnd = _time);
                      }
                    },
                    icon: Icon(
                      Icons.access_time,
                      color: Colors.black54,
                      size: 16.0,
                    ),
                    label: Text(
                      nightEnd,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.black38, width: 1),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: kBottomBorderDecoration,
                child: CustomIconLabel(
                  icon: Icon(Icons.list_alt, color: Colors.black54),
                  label: '雇用形態 (カンマ区切りで入力してください)',
                ),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 40.0),
              Center(
                child: CustomLinkButton(
                  onTap: () {},
                  color: Colors.red,
                  label: 'この会社/組織を削除申請する',
                ),
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ],
    );
  }
}
