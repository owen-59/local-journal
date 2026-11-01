import "package:flutter/material.dart";

/// Returns the amount of weeks in month given by [dt],
/// including non-full weeks.
int getWeeksInMonth(DateTime dt) {
  final daysInMonth = DateUtils.getDaysInMonth(dt.year, dt.month);
  final offset = DateUtils.firstDayOffset(
    dt.year,
    dt.month,
    DefaultMaterialLocalizations(),
  );

  return ((daysInMonth + offset) / 7).ceil();
}
