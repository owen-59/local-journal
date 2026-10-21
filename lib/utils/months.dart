import 'package:flutter/material.dart';

int getWeeksInMonth(DateTime dt) {
  final daysInMonth = DateUtils.getDaysInMonth(dt.year, dt.month);
  final offset = DateUtils.firstDayOffset(
    dt.year,
    dt.month,
    DefaultMaterialLocalizations(),
  );

  return ((daysInMonth + offset) / 7).ceil();
}
