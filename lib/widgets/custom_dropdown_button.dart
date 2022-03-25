import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final dynamic value;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final bool? isExpanded;

  CustomDropdownButton({
    this.value,
    this.onChanged,
    this.items,
    this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: isExpanded ?? false,
          value: value,
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}
