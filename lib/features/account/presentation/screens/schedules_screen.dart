import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/features/account/presentation/widgets/delete_schedule_bottom_sheet.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCreating = false;
  final Set<String> _selectedDays = {'Mon', 'Tue'};

  final _sessionNameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final GlobalKey _dateFieldKey = GlobalKey();
  final GlobalKey _timeFieldKey = GlobalKey();

  final _scanSessions = [
    _ScheduleItem(
      title: 'Morning Check',
      subtitle: 'Monday & Thursday',
      time: '7:00pm',
    ),
    _ScheduleItem(title: 'Weekend Scan', subtitle: 'Saturday', time: '10:00am'),
  ];

  final _repairSessions = [
    _ScheduleItem(
      title: 'Oil Change',
      subtitle: 'March 15, 2026',
      time: '7:00pm',
      description: 'Due every 5,000 miles',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sessionNameCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _noteCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: RapidAppBar(
        title: 'Schedules',
        onLeadingPressed: _isCreating
            ? () => setState(() => _isCreating = false)
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Fixed top: TabBar ──
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                splashBorderRadius: BorderRadius.circular(100.r),
                unselectedLabelColor: AppColors.grey600,
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Scan Sessions'),
                  Tab(text: 'Repair Sessions'),
                ],
              ),
            ),
          ),

          if (_isCreating)
            Expanded(child: _buildCreateForm())
          else ...[
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              child: _buildCreateNewBanner(),
            ),

            // ── Scrollable tab content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSessionList(_scanSessions),
                  _buildSessionList(_repairSessions),
                ],
              ),
            ),

            // ── Footer ──
            Padding(
              padding: EdgeInsets.only(bottom: 32.h, top: 16.h),
              child: Text(
                'Rapid V1.2',
                style: AppTextStyles.rapidVersion,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateNewBanner() {
    final isScan = _tabController.index == 0;
    final description = isScan
        ? "Set up auto scan sessions. We'll remind you to start scanning at your scheduled time."
        : "Schedule repair & maintenance reminders so you never miss a service appointment.";

    return GestureDetector(
      onTap: () {
        setState(() {
          _isCreating = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Fade description text when tab switches
                  Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      )
                      .animate(key: ValueKey(isScan))
                      .fadeIn(duration: 300.ms, curve: Curves.easeIn),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5.w,
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 24.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    final isScan = _tabController.index == 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // White Card
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isScan ? 'New Scan Schedule' : 'New Repair Reminder',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isScan
                      ? "Set up recurring auto scan sessions for your vehicle. We'll remind you and start scanning at your scheduled time."
                      : "Schedule repair & maintenance reminders so you never miss a service appointment.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.black300,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          _buildFormLabel('SESSION NAME'),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: _sessionNameCtrl,
            hint: 'e.g. Morning Check',
          ),
          SizedBox(height: 24.h),

          if (isScan) ...[
            _buildFormLabel('DAYS'),
            SizedBox(height: 12.h),
            _buildDaysSelector(),
            SizedBox(height: 24.h),
            _buildFormLabel('TIME'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: _timeCtrl,
              hint: '08:00 AM',
              icon: Assets.clock,
              fieldKey: _timeFieldKey,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();
                _showDropdown(
                  context,
                  _timeFieldKey,
                  (close) => _TimeDropdownUI(
                    onClose: close,
                    onChanged: (val) => _timeCtrl.text = val,
                  ),
                );
              },
            ),
          ] else ...[
            _buildFormLabel('DATE'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: _dateCtrl,
              hint: 'mm/dd/yy',
              icon: Assets.calendar,
              fieldKey: _dateFieldKey,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();

                DateTime? parsedDate;
                if (_dateCtrl.text.isNotEmpty) {
                  try {
                    final parts = _dateCtrl.text.split('/');
                    if (parts.length == 3) {
                      int month = int.parse(parts[0]);
                      int day = int.parse(parts[1]);
                      int year = 2000 + int.parse(parts[2]);
                      parsedDate = DateTime(year, month, day);
                    }
                  } catch (_) {}
                }

                _showDropdown(
                  context,
                  _dateFieldKey,
                  (close) => _DateDropdownUI(
                    onClose: close,
                    initialDate: parsedDate,
                    onChanged: (val) => _dateCtrl.text = val,
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            _buildFormLabel('TIME'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: _timeCtrl,
              hint: '08:00 AM',
              icon: Assets.clock,
              fieldKey: _timeFieldKey,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();
                _showDropdown(
                  context,
                  _timeFieldKey,
                  (close) => _TimeDropdownUI(
                    onClose: close,
                    onChanged: (val) => _timeCtrl.text = val,
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            _buildFormLabel('NOTE (OPTIONAL)'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: _noteCtrl,
              hint: 'e.g. Due every 3 months',
            ),
          ],

          SizedBox(height: 48.h),

          // Save Schedule
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCreating = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Schedule',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Cancel
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isCreating = false;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textVeryDarkGrey,
                ),
              ),
            ),
          ),

          SizedBox(height: 40.h),

          Center(child: Text('Rapid V1.2', style: AppTextStyles.rapidVersion)),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.grey500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? icon,
    GlobalKey? fieldKey,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return RapidTextField(
      key: fieldKey,
      controller: controller,
      hintText: hint,
      readOnly: readOnly,
      onTap: onTap,
      backgroundColor: const Color(0xFFF3F4F6),
      inactiveBorderColor: AppColors.borderColor2,
      prefixIcon: icon != null
          ? SvgPicture.asset(
              icon,
              height: 20.w,
              width: 20.w,
              colorFilter: const ColorFilter.mode(
                AppColors.black300,
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }

  Widget _buildDaysSelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 12.h,
      children: days.map((day) {
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionList(List<_ScheduleItem> items) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = items[index];
        // Each card fades in with a staggered delay
        return _buildScheduleCard(item).animate().fadeIn(
          duration: 300.ms,
          delay: (60 * index).ms,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget _buildScheduleCard(_ScheduleItem item) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(Assets.scheduleGrey),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.asset(Assets.clock),
                          SizedBox(width: 4.w),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.black300,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDeleteScheduleBottomSheet(context),
            icon: SvgPicture.asset(Assets.binRed),
          ),
        ],
      ),
    );
  }

  void _showDropdown(
    BuildContext context,
    GlobalKey fieldKey,
    Widget Function(VoidCallback closeLocal) builder,
  ) {
    if (fieldKey.currentContext == null) return;

    final RenderBox renderBox =
        fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    OverlayEntry? overlayEntry;

    void closeOverlay() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: closeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4.h,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: builder(closeOverlay),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }
}

class _TimeDropdownUI extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;
  const _TimeDropdownUI({required this.onClose, required this.onChanged});

  @override
  State<_TimeDropdownUI> createState() => _TimeDropdownUIState();
}

class _TimeDropdownUIState extends State<_TimeDropdownUI> {
  int hour = 12;
  int minute = 0;
  bool isAm = true;

  void _update() {
    widget.onChanged(
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isAm ? 'AM' : 'PM'}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderColor2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSpinner(
              value: hour.toString().padLeft(2, '0'),
              onUp: () {
                setState(() => hour = hour == 12 ? 1 : hour + 1);
                _update();
              },
              onDown: () {
                setState(() => hour = hour == 1 ? 12 : hour - 1);
                _update();
              },
            ),
            Text(
              ":",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            _buildSpinner(
              value: minute.toString().padLeft(2, '0'),
              onUp: () {
                setState(() => minute = minute == 59 ? 0 : minute + 1);
                _update();
              },
              onDown: () {
                setState(() => minute = minute == 0 ? 59 : minute - 1);
                _update();
              },
            ),
            SizedBox(width: 8.w),
            _buildSpinner(
              value: isAm ? 'AM' : 'PM',
              onUp: () {
                setState(() => isAm = !isAm);
                _update();
              },
              onDown: () {
                setState(() => isAm = !isAm);
                _update();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onUp,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: AppColors.textVeryDarkGrey,
            size: 24.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onDown,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textVeryDarkGrey,
            size: 24.w,
          ),
        ),
      ],
    );
  }
}

class _DateDropdownUI extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;
  final DateTime? initialDate;
  const _DateDropdownUI({
    required this.onClose,
    required this.onChanged,
    this.initialDate,
  });

  @override
  State<_DateDropdownUI> createState() => _DateDropdownUIState();
}

class _DateDropdownUIState extends State<_DateDropdownUI> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        widget.initialDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SfDateRangePicker(
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          if (args.value is DateTime) {
            final date = args.value as DateTime;
            setState(() => _selectedDate = date);
            widget.onChanged(
              '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}',
            );
            widget.onClose();
          }
        },
        selectionMode: DateRangePickerSelectionMode.single,
        initialSelectedDate: _selectedDate,
        backgroundColor: Colors.transparent,

        headerStyle: DateRangePickerHeaderStyle(
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textVeryDarkGrey,
          ),
          backgroundColor: Colors.transparent,
          textAlign: TextAlign.center,
        ),
        headerHeight: 50.h,
        navigationDirection: DateRangePickerNavigationDirection.horizontal,
        showNavigationArrow: true,
        monthViewSettings: DateRangePickerMonthViewSettings(
          numberOfWeeksInView: 5,
          dayFormat: 'EE',
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            textStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black300,
            ),
          ),
        ),
        selectionColor: Colors.transparent,
        selectionRadius: 0,
        todayHighlightColor: Colors.transparent,
        monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textVeryDarkGrey,
          ),
          trailingDatesTextStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey200,
          ),
          leadingDatesTextStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey200,
          ),
        ),
        cellBuilder:
            (BuildContext context, DateRangePickerCellDetails details) {
              final isSelected =
                  _selectedDate.year == details.date.year &&
                  _selectedDate.month == details.date.month &&
                  _selectedDate.day == details.date.day;

              final midDate =
                  details.visibleDates[details.visibleDates.length ~/ 2];
              final isCurrentMonth = details.date.month == midDate.month;

              Color textColor;
              if (isSelected) {
                textColor = Colors.white;
              } else if (isCurrentMonth) {
                textColor = AppColors.textVeryDarkGrey;
              } else {
                textColor = AppColors.grey200;
              }

              return Container(
                alignment: Alignment.center,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    details.date.day.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }
}

class _ScheduleItem {
  final String title;
  final String subtitle;
  final String time;
  final String? description;

  const _ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.description,
  });
}
