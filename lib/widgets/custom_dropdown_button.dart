import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? label;
  final dynamic value;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final bool? isExpanded;

  CustomDropdownButton({
    this.label,
    this.value,
    this.onChanged,
    this.items,
    this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: isExpanded ?? false,
              value: value ?? null,
              onChanged: onChanged ?? null,
              items: items ?? [],
            ),
          ),
        ),
      ],
    );
  }
}
