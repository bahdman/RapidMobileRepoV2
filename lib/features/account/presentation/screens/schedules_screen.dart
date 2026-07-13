import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/features/account/presentation/widgets/delete_schedule_bottom_sheet.dart';
import 'package:rapid_app/core/services/schedule_service.dart';
import 'package:dio/dio.dart';

const Map<String, int> _dayMap = {
  'Sun': 0,
  'Mon': 1,
  'Tue': 2,
  'Wed': 3,
  'Thu': 4,
  'Fri': 5,
  'Sat': 6,
};

const Map<int, String> _dayReverseMap = {
  0: 'Sunday',
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
};

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

  List<_ScheduleItem> _scanSessions = [];
  List<_ScheduleItem> _repairSessions = [];
  bool _isLoadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _fetchSchedules();
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

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
    });
    try {
      final scheduleService = context.read<ScheduleService>();
      final schedules = await scheduleService.getAllSchedules();
      
      final List<_ScheduleItem> scans = [];
      final List<_ScheduleItem> repairs = [];

      for (var schedule in schedules) {
        final isScan = schedule.note.startsWith('[Scan]');
        
        if (isScan) {
          final daysList = schedule.entries.map((e) => _dayReverseMap[e.day] ?? 'Monday').toList();
          final daysStr = daysList.join(' & ');
          
          String timeStr = '08:00 AM';
          if (schedule.entries.isNotEmpty) {
            try {
              final parsedTime = DateTime.parse(schedule.entries.first.time).toLocal();
              final isPm = parsedTime.hour >= 12;
              final hour = parsedTime.hour % 12 == 0 ? 12 : parsedTime.hour % 12;
              timeStr = '${hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
            } catch (_) {}
          }

          scans.add(_ScheduleItem(
            id: schedule.id,
            title: schedule.name,
            subtitle: daysStr,
            time: timeStr,
          ));
        } else {
          String noteContent = schedule.note.replaceFirst('[Repair]', '').trim();
          
          String dateStr = '';
          String timeStr = '08:00 AM';
          if (schedule.entries.isNotEmpty) {
            try {
              final parsedTime = DateTime.parse(schedule.entries.first.time).toLocal();
              final isPm = parsedTime.hour >= 12;
              final hour = parsedTime.hour % 12 == 0 ? 12 : parsedTime.hour % 12;
              timeStr = '${hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
              
              final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
              dateStr = '${months[parsedTime.month - 1]} ${parsedTime.day}, ${parsedTime.year}';
            } catch (_) {}
          }

          repairs.add(_ScheduleItem(
            id: schedule.id,
            title: schedule.name,
            subtitle: dateStr,
            time: timeStr,
            description: noteContent.isNotEmpty ? noteContent : null,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _scanSessions = scans;
          _repairSessions = repairs;
        });
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSchedules = false;
        });
      }
    }
  }

  Future<void> _deleteSchedule(String id) async {
    try {
      final scheduleService = context.read<ScheduleService>();
      final success = await scheduleService.deleteSchedules([id]);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchSchedules();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete schedule.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting schedule: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        int month = int.parse(parts[0]);
        int day = int.parse(parts[1]);
        int year = 2000 + int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime.now();
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final cleanStr = timeStr.trim().toUpperCase();
      final parts = cleanStr.split(' ');
      if (parts.length == 2) {
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        final isPm = parts[1] == 'PM';
        if (isPm && hour != 12) {
          hour += 12;
        } else if (!isPm && hour == 12) {
          hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> _saveSchedule() async {
    final name = _sessionNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }

    final isScan = _tabController.index == 0;
    try {
      final scheduleService = context.read<ScheduleService>();
      
      List<ScheduleEntry> entries = [];
      String note = '';

      if (isScan) {
        note = '[Scan]';
        if (_selectedDays.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one day')),
          );
          return;
        }
        if (_timeCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time')),
          );
          return;
        }

        final parsedTime = _parseTimeOfDay(_timeCtrl.text);
        final now = DateTime.now();
        final targetTime = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);

        entries = _selectedDays.map((dayStr) {
          final dayIndex = _dayMap[dayStr] ?? 1;
          return ScheduleEntry(
            id: '',
            day: dayIndex,
            time: targetTime.toUtc().toIso8601String(),
          );
        }).toList();
      } else {
        final rawNote = _noteCtrl.text.trim();
        note = rawNote.isNotEmpty ? '[Repair] $rawNote' : '[Repair]';
        
        if (_dateCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date')),
          );
          return;
        }
        if (_timeCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time')),
          );
          return;
        }

        final parsedDate = _parseDate(_dateCtrl.text);
        final parsedTime = _parseTimeOfDay(_timeCtrl.text);
        final targetTime = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, parsedTime.hour, parsedTime.minute);

        entries = [
          ScheduleEntry(
            id: '',
            day: targetTime.weekday % 7,
            time: targetTime.toUtc().toIso8601String(),
          )
        ];
      }

      final created = await scheduleService.createSchedule(
        name: name,
        note: note,
        entries: entries,
      );

      if (created != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isCreating = false;
          _sessionNameCtrl.clear();
          _dateCtrl.clear();
          _timeCtrl.clear();
          _noteCtrl.clear();
          _selectedDays.clear();
        });
        _fetchSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save schedule: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffoldBg : AppColors.scaffoldBg,
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
                color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: isDark ? AppColors.darkTextPrimary : Colors.black,
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
              child: _isLoadingSchedules
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScan = _tabController.index == 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Card
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
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
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isScan
                      ? "Set up recurring auto scan sessions for your vehicle. We'll remind you and start scanning at your scheduled time."
                      : "Schedule repair & maintenance reminders so you never miss a service appointment.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.darkTextSub : AppColors.black300,
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
              onPressed: _saveSchedule,
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
                  color: isDark ? AppColors.darkTextSub : AppColors.textVeryDarkGrey,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextSub : AppColors.grey500,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RapidTextField(
      key: fieldKey,
      controller: controller,
      hintText: hint,
      readOnly: readOnly,
      onTap: onTap,
      backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
      inactiveBorderColor: isDark ? AppColors.darkBorder : AppColors.borderColor2,
      prefixIcon: icon != null
          ? SvgPicture.asset(
              icon,
              height: 20.w,
              width: 20.w,
              colorFilter: ColorFilter.mode(
                isDark ? AppColors.darkTextSub : AppColors.black300,
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }

  Widget _buildDaysSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isSelected
                  ? AppColors.blue
                  : (isDark ? AppColors.darkSurface2 : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : Colors.black),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.02),
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
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? AppColors.darkTextSub : AppColors.black300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.asset(
                            Assets.clock,
                            colorFilter: isDark
                                ? const ColorFilter.mode(AppColors.darkTextSub, BlendMode.srcIn)
                                : null,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? AppColors.darkTextSub : AppColors.black300,
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
                            color: isDark ? AppColors.darkTextSub : AppColors.black300,
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
            onPressed: () async {
              final confirmed = await showDeleteScheduleBottomSheet(context);
              if (confirmed == true) {
                _deleteSchedule(item.id);
              }
            },
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

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response != null && response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map.containsKey('message') && map['message'] != null) {
          return map['message'].toString();
        }
      }
      return e.message ?? 'A network error occurred';
    }
    return e.toString();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.borderColor2,
          ),
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
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onUp,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: isDark ? AppColors.darkTextSub : AppColors.textVeryDarkGrey,
            size: 24.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextPrimary : Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onDown,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? AppColors.darkTextSub : AppColors.textVeryDarkGrey,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 340.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.05),
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
            color: isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
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
            color: isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
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
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkSurface2 : Colors.white),
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
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String? description;

  const _ScheduleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.description,
  });
}
