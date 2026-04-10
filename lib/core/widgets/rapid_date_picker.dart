import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

/// A custom scrollable date picker with three independent wheels:
/// Month (name), Day (number), and Year (number).
///
/// Styled to match the app's design — selected item is bold/dark,
/// surrounding items fade out progressively.
class RapidDatePicker extends StatefulWidget {
  /// Initial month (1–12), defaults to current month.
  final int initialMonth;

  /// Initial day (1–31), defaults to current day.
  final int initialDay;

  /// Initial year, defaults to current year minus 18.
  final int initialYear;

  /// Minimum selectable year (inclusive).
  final int minYear;

  /// Maximum selectable year (inclusive).
  final int maxYear;

  /// Called whenever the user scrolls to a new date.
  final ValueChanged<DateTime>? onDateChanged;

  const RapidDatePicker({
    super.key,
    this.initialMonth = 1,
    this.initialDay = 1,
    this.initialYear = 2000,
    this.minYear = 1920,
    this.maxYear = 2026,
    this.onDateChanged,
  });

  @override
  State<RapidDatePicker> createState() => RapidDatePickerState();
}

class RapidDatePickerState extends State<RapidDatePicker> {
  static const int _visibleItems = 5;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  late int _selectedMonth; // 1-12
  late int _selectedDay; // 1-31
  late int _selectedYear;

  List<int> get _years => List.generate(
    widget.maxYear - widget.minYear + 1,
    (i) => widget.minYear + i,
  );

  int get _daysInMonth {
    // Account for leap year
    if (_selectedMonth == 2) {
      final isLeap =
          (_selectedYear % 4 == 0 && _selectedYear % 100 != 0) ||
          (_selectedYear % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const daysPerMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[_selectedMonth];
  }

  /// Returns the currently selected date.
  DateTime get selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth.clamp(1, 12);
    _selectedDay = widget.initialDay.clamp(1, 31);
    _selectedYear = widget.initialYear.clamp(widget.minYear, widget.maxYear);

    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - widget.minYear,
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    // Clamp day if month/year changed and day exceeds max
    final maxDay = _daysInMonth;
    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;
      _dayController.jumpToItem(_selectedDay - 1);
    }
    widget.onDateChanged?.call(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final double itemExtent = 65.h;
    final double pickerHeight = itemExtent * _visibleItems;

    return Container(
      color: Colors.transparent,
      height: pickerHeight,
      child: Stack(
        children: [
          // Selection highlight band
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: itemExtent,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.grey200, width: 0.5),
                    bottom: BorderSide(color: AppColors.grey200, width: 0.5),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              // Month wheel
              Expanded(
                flex: 3,
                child: _buildWheel(
                  controller: _monthController,
                  itemCount: 12,
                  labelBuilder: (index) => _monthNames[index],
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMonth = index + 1;
                      _onDateChanged();
                    });
                  },
                  selectedIndex: _selectedMonth - 1,
                  itemExtent: itemExtent,
                ),
              ),
              // Day wheel
              Expanded(
                flex: 2,
                child: _buildWheel(
                  controller: _dayController,
                  itemCount: _daysInMonth,
                  labelBuilder: (index) => '${index + 1}',
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDay = index + 1;
                      _onDateChanged();
                    });
                  },
                  selectedIndex: _selectedDay - 1,
                  itemExtent: itemExtent,
                ),
              ),
              // Year wheel
              Expanded(
                flex: 2,
                child: _buildWheel(
                  controller: _yearController,
                  itemCount: _years.length,
                  labelBuilder: (index) => '${_years[index]}',
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedYear = _years[index];
                      _onDateChanged();
                    });
                  },
                  selectedIndex: _selectedYear - widget.minYear,
                  itemExtent: itemExtent,
                ),
              ),
            ],
          ),
          // Top and bottom fade overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: itemExtent * 1.5,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffF7F7F7).withValues(alpha: 0.6),
                      Color(0xffF7F7F7).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: itemExtent * 1.5,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xffF7F7F7).withValues(alpha: 0.6),
                      Color(0xffF7F7F7).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required ValueChanged<int> onSelectedItemChanged,
    required int selectedIndex,
    required double itemExtent,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 100, // Nearly flat — no curvature
      perspective: 0.001,
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = index == selectedIndex;
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.grey200.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              labelBuilder(index),
              style: TextStyle(
                fontSize: isSelected ? 22.sp : 18.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Color(0xff5F5858) : Color(0xffC3C3C3),
              ),
            ),
          );
        },
      ),
    );
  }
}
