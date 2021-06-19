class BreaksModel {
  String _id;
  DateTime startedAt;
  double startedLat;
  double startedLon;
  DateTime endedAt;
  double endedLat;
  double endedLon;

  String get id => _id;

  BreaksModel.fromMap(Map data) {
    _id = data['id'];
    startedAt = data['startedAt'].toDate();
    startedLat = data['startedLat'].toDouble();
    startedLon = data['startedLon'].toDouble();
    endedAt = data['endedAt'].toDate();
    endedLat = data['endedLat'].toDouble();
    endedLon = data['endedLon'].toDouble();
  }

  Map toMap() => {
        'id': id,
        'startedAt': startedAt,
        'startedLat': startedLat,
        'startedLon': startedLon,
        'endedAt': endedAt,
        'endedLat': endedLat,
        'endedLon': endedLon,
      };

  String breakTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // 休憩開始時間と休憩終了時間の差を求める
    Duration _diff = endedAt.difference(startedAt);
    String _minutes = twoDigits(_diff.inMinutes.remainder(60));
    return '${twoDigits(_diff.inHours)}:$_minutes';
  }
}
