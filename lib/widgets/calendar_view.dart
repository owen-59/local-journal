import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:journal/providers/day_image.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/utils/months.dart';
import 'package:journal/widgets/error_card.dart';
import 'package:measured/measured.dart';

double getGridLineHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).width / 7;
}

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key, required this.goToDate});
  final void Function(DateTime) goToDate;

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  final _centerKey = const ValueKey<String>("center-sliver-key");
  final _currentDt = DateTime.now();

  double _monthTitleHeight = 100;

  DateTime _getMonthForIndex(int index) {
    return DateTime(_currentDt.year, _currentDt.month + index, 1);
  }

  double _getHeightForIndex(int index) {
    final month = _getMonthForIndex(index);
    final rows = getWeeksInMonth(month);
    final rowsHeight = getGridLineHeight(context) * rows;
    return _monthTitleHeight + rowsHeight;
  }

  @override
  Widget build(BuildContext context) {
    final entriesList = ref.watch(entryListProvider);

    return Stack(
      children: [
        switch (entriesList) {
          AsyncData() => CustomScrollView(
            center: _centerKey,
            slivers: [
              SliverVariedExtentList.builder(
                itemBuilder: (context, index) {
                  final month = _getMonthForIndex(-index - 1);
                  return MonthSectionWidget(
                    key: ValueKey(month),
                    month: month,
                    goToDate: widget.goToDate,
                  );
                },
                itemExtentBuilder: (index, _) => _getHeightForIndex(-index - 1),
              ),
              SliverVariedExtentList.builder(
                key: _centerKey,
                itemBuilder: (context, index) {
                  final month = _getMonthForIndex(index);
                  return MonthSectionWidget(
                    key: ValueKey(month),
                    month: month,
                    goToDate: widget.goToDate,
                  );
                },
                itemExtentBuilder: (index, _) => _getHeightForIndex(index),
              ),
            ],
          ),
          AsyncError(:final error, :final stackTrace) => ErrorCard(
            error: error,
            stackTrace: stackTrace,
          ),
          AsyncLoading() => Center(child: CircularProgressIndicator()),
        },
        Offstage(
          child: Measured(
            onChanged: (size) {
              if (_monthTitleHeight != size.height) {
                setState(() => _monthTitleHeight = size.height);
              }
            },
            child: Text(
              "February 2026",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class MonthSectionWidget extends StatelessWidget {
  final DateTime month;
  final void Function(DateTime) goToDate;
  const MonthSectionWidget({
    super.key,
    required this.month,
    required this.goToDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMM().format(month),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Table(
          defaultColumnWidth: const FlexColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: List.generate(
            getWeeksInMonth(month),
            (week) => TableRow(
              children: List.generate(7, (day) {
                final date = month.copyWith(
                  day:
                      7 * week +
                      day -
                      DateUtils.firstDayOffset(
                        month.year,
                        month.month,
                        DefaultMaterialLocalizations(),
                      ) +
                      1,
                );
                final isInMonth = date.month == month.month;
                if (isInMonth) {
                  return DayCell(dt: date, goToDate: goToDate);
                } else {
                  return SizedBox(
                    height: getGridLineHeight(context),
                    child: Center(
                      child: Text(
                        "",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  );
                }
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class DayCell extends ConsumerWidget {
  final DateTime dt;
  final void Function(DateTime) goToDate;
  const DayCell({super.key, required this.dt, required this.goToDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(dayImageProvider(dt));
    final dimension = getGridLineHeight(context);
    final imageCacheDimension =
        (dimension * MediaQuery.devicePixelRatioOf(context)).round();

    return SizedBox(
      height: getGridLineHeight(context),
      child: GestureDetector(
        onTap: () => goToDate(dt),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Center(
              child: Text(
                "${dt.day}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            switch (image) {
              AsyncData(:final value) =>
                value != null
                    ? SizedBox.square(
                        dimension: getGridLineHeight(context),
                        child: ClipRect(
                          child: Image.memory(
                            value,
                            fit: BoxFit.cover,
                            cacheWidth: imageCacheDimension,
                            frameBuilder: (_, child, frame, _) => frame == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : child,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              _ => SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }
}
