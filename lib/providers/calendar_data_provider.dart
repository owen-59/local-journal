import 'package:flutter/material.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "calendar_data_provider.g.dart";

class CalendarDayData {
  final List<DateTime> entriesDts;
  const CalendarDayData({required this.entriesDts});
}

class CalendarMonthData {
  final int length;
  final int offset;
  final List<CalendarDayData> dayData;

  const CalendarMonthData({
    required this.length,
    required this.offset,
    required this.dayData,
  });
}

@riverpod
Future<CalendarMonthData> calendarData(Ref ref, DateTime month) async {
  logger.i("Starting load of $month");
  final entries = await ref.watch(entryListProvider.future);
  final length = DateUtils.getDaysInMonth(month.year, month.month);
  final offset = DateUtils.firstDayOffset(
    month.year,
    month.month,
    DefaultMaterialLocalizations(),
  );

  final days = List.generate(length, (i) => i + 1)
      .map((day) => month.copyWith(day: day))
      .map(
        (day) => CalendarDayData(
          entriesDts: entries
              .where((entryDt) => DateUtils.isSameMonth(entryDt, day))
              .toList(),
        ),
      )
      .toList();

  return CalendarMonthData(length: length, offset: offset, dayData: days);
}
