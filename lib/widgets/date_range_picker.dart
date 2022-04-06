import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangePicker extends StatelessWidget {
  final List<DateTime>? initialSelectedDates;
  final Function(DateRangePickerSelectionChangedArgs)? onSelectionChanged;

  DateRangePicker({
    this.initialSelectedDates,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SfDateRangePicker(
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.multiple,
        initialSelectedDates: initialSelectedDates,
        selectionColor: Colors.redAccent,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}
