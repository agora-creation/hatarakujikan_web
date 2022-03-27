import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final Color color;

  Loading({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitDualRing(
        color: color,
        size: 32.0,
      ),
    );
  }
}
