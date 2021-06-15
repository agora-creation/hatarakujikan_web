import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/widgets/custom_text_button.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  ErrorDialog(this.message);

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
              size: 32.0,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            message,
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
                onPressed: () => Navigator.pop(context),
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
