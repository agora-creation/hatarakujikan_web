import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  ErrorMessage({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.report_problem,
              color: Colors.red,
              size: 64.0,
            ),
          ),
          SizedBox(height: 24.0),
          Text(
            message,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextButton(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.grey,
                labelText: 'キャンセル',
              ),
              CustomTextButton(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.blue,
                labelText: 'はい',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
