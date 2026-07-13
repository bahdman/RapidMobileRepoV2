import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/services/obd_service.dart';
import 'package:rapid_app/core/services/obd_connection_service.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/bluetooth_bloc.dart';
import 'package:rapid_app/features/home/presentation/screens/code_search_screen.dart';
import 'package:rapid_app/features/notifications/presentation/screens/bloc/notification_bloc.dart';
import 'package:rapid_app/route_names.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ObdHistoryItem> _historyItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (!refresh && _historyItems.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final obdService = context.read<ObdService>();
      final history = await obdService.getSearchHistory(limit: 20, refresh: refresh);
      if (mounted) {
        setState(() {
          _historyItems = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading home history: $e');
    } finally {
      if (mounted && !refresh) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeaderHeight = 430.h;
    final double minHeaderHeight = MediaQuery.of(context).padding.top + 220.h;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: DefaultTabController(
        length: 2,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            int unreadCount = 0;
            if (state is NotificationLoaded) {
              unreadCount = state.notifications.where((n) => !n.isRead).length;
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _DashboardHeaderDelegate(
                      maxExtent: maxHeaderHeight,
                      minExtent: minHeaderHeight,
                      context: context,
                      unreadCount: unreadCount,
                      onRefreshHistory: () => _loadHistory(refresh: true),
                    ),
                  ),
                ];
              },
              body: Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBarView(
                  children: [
                    _recentScansList().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    const Center(child: Text('Vehicle Health Content')).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _recentScansList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final Widget child;
    if (_historyItems.isEmpty) {
      child = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Text(
                  'No recent scans found.',
                  style: TextStyle(
                    color: AppColors.textMediumGrey,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      child = ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _historyItems.length,
        separatorBuilder: (_, __) => SizedBox(height: 24.h),
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          String dateStr = '${months[item.searchedAt.month - 1]} ${item.searchedAt.day}, ${item.searchedAt.year}';
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _groupHeader(dateStr),
              _historyItem(
                'Code: ${item.query}',
                'Scanned via ${item.searchType}',
                item.query,
              ),
            ],
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistory(refresh: true),
      color: AppColors.primary,
      child: child,
    );
  }

  Widget _groupHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textMediumGrey,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _historyItem(String title, String subtitle, String query) {
    return InkWell(
      onTap: () async {
        final result = await context.pushNamed(AppRoutes.codeSearch, extra: query);
        if (result == true) {
          _loadHistory(refresh: true);
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            Assets.arrowRight,
            height: 16.h,
            colorFilter: const ColorFilter.mode(
              AppColors.textDarkGrey,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double maxExtent;
  @override
  final double minExtent;
  final BuildContext context;
  final int unreadCount;
  final VoidCallback onRefreshHistory;

  _DashboardHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
    required this.context,
    required this.unreadCount,
    required this.onRefreshHistory,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double fadeStart = 0.0;
    final double fadeEnd = maxExtent - minExtent;
    final double progress = (shrinkOffset - fadeStart) / (fadeEnd - fadeStart);
    final double opacity = (1 - progress).clamp(0.0, 1.0);

    return Container(
      color: AppColors.primary,
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logo Row (Always Visible)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.logoWhite, height: 32.h),
                      Expanded(
                        child: Text(
                          'Search for a code or scan fast',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed(AppRoutes.notification),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              Assets.notification,
                              height: 28.h,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3B30),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 2. Fading Section (Search & Chips)
                Opacity(
                  opacity: opacity,
                  child: SizedBox(
                    height: (150.h * opacity).clamp(0, 150.h),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Hero(
                              tag: kInputCodeHeroTag,
                              child: Material(
                                color: Colors.transparent,
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await context.pushNamed(AppRoutes.codeSearch);
                                    if (result == true) {
                                      onRefreshHistory();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 20.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        100.r,
                                      ),
                                    ),
                                    child: TextField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        hintText: 'Input code',
                                        hintStyle: TextStyle(
                                          color: AppColors.hintGrey,
                                          fontSize: 15.sp,
                                        ),
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),
                          _tagsRow(),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                // 3. Connect Buttons Row (Always Visible)
                _actionButtonsRow(),
              ],
            ),
          ),

          // 4. Pinned TabBar at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r * (1 - progress).clamp(0.0, 1.0)),
                ),
              ),
              child: TabBar(
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: AppColors.primary),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: AppColors.textMediumGrey,
                labelStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Recent scans'),
                  Tab(text: 'Vehicle Health'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagsRow() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tagItem('C0074'),
          _tagItem('P0A01'),
          _tagItem('P0001'),
          _tagItem('B1365'),
          _tagItem('P0420'),
        ],
      ),
    );
  }

  Widget _tagItem(String text) {
    return GestureDetector(
      onTap: () async {
        final result = await context.pushNamed(AppRoutes.codeSearch, extra: text);
        if (result == true) {
          onRefreshHistory();
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryDisabled,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _actionButtonsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 10.h),
      child: Row(
        children: [
          Expanded(
            child: RapidButton(
              text: 'Connect Directly',
              onPressed: () {
                context.pushNamed(AppRoutes.bluetooth);
                context.read<BluetoothBloc>().add(
                  const DeviceSelected(
                    BluetoothDevice(
                      id: 'wifi:192.168.0.10:35000',
                      name: 'WiFi OBD Adapter',
                      transport: ObdTransport.wifi,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.connectDirectBlue,
              textColor: Colors.white,
              fontSize: 13.sp,
              borderRadius: 100.r,
              fontWeight: FontWeight.w500,
              icon: SvgPicture.asset(
                Assets.wifi,
                height: 24.h,
                width: 24.w,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: RapidButton(
              text: 'Connect with OBD',
              onPressed: () => context.pushNamed(AppRoutes.bluetooth),
              backgroundColor: AppColors.connectObdBlue,
              textColor: Colors.white,
              fontSize: 13.sp,
              borderRadius: 100.r,
              fontWeight: FontWeight.w500,
              icon: SvgPicture.asset(
                Assets.bluetoothGrey,
                height: 24.h,
                width: 24.w,
                colorFilter: const ColorFilter.mode(
                  Color(0xff79B9FF),
                  BlendMode.srcIn,
                ),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DashboardHeaderDelegate oldDelegate) {
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent ||
        context != oldDelegate.context ||
        unreadCount != oldDelegate.unreadCount ||
        onRefreshHistory != oldDelegate.onRefreshHistory;
  }
}
