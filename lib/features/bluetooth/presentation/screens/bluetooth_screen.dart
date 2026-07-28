import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';

import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/route_names.dart';
import 'bloc/bluetooth_bloc.dart';

class BluetoothScreen extends StatefulWidget {
  final bool isWifi;
  const BluetoothScreen({super.key, this.isWifi = false});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    // Add StartSearch event when screen is opened
    context.read<BluetoothBloc>().add(StartSearch(isWifiOnly: widget.isWifi));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: RapidAppBar(title: widget.isWifi ? 'Wi-Fi' : 'Bluetooth'),
      body: BlocListener<BluetoothBloc, BluetoothState>(
        listener: (context, state) {
          if (state is BluetoothConnected) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.pushNamed(AppRoutes.scanning);
              }
            });
          }
        },
        child: BlocBuilder<BluetoothBloc, BluetoothState>(
          builder: (context, state) {
            return Column(
                  children: [
                    SizedBox(height: 32.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _headerSection(state),
                    ),
                    SizedBox(height: 24.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildContent(context, state),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
          },
        ),
      ),
    );
  }

  Widget _headerSection(BluetoothState state) {
    final modeName = widget.isWifi ? 'Wi-Fi' : 'Bluetooth';
    String title = 'Searching for $modeName devices';
    String subtitle = 'Looking nearby...';

    if (state is BluetoothDevicesFound) {
      if (state.isScanning) {
        title = 'Searching for $modeName devices';
        subtitle =
            '${state.devices.length} device${state.devices.length == 1 ? '' : 's'} found so far...';
      } else {
        title = state.devices.isEmpty ? 'Scan Complete' : 'Devices Discovered';
        subtitle = state.devices.isEmpty
            ? 'No $modeName OBD adapters found'
            : '${state.devices.length} device${state.devices.length == 1 ? '' : 's'} ready to connect';
      }
    } else if (state is BluetoothConnecting) {
      subtitle = 'Connecting...';
    } else if (state is BluetoothConnected) {
      title = 'Connected';
      subtitle = 'Device ready to use';
    } else if (state is BluetoothPermissionDenied) {
      title = 'Permission Required';
      subtitle = '$modeName access needed';
    } else if (state is BluetoothError) {
      title = 'Connection Error';
      subtitle = state.message;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textMediumGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BluetoothState state) {
    if (state is BluetoothSearching) {
      return Column(
        children: [
          _hardwareGuidanceBanner(context),
          SizedBox(height: 32.h),
          PulsatingDeviceIcon(isWifi: widget.isWifi),
        ],
      );
    }

    if (state is BluetoothPermissionDenied) {
      return _permissionDeniedCard(context);
    }

    if (state is BluetoothError) {
      return _errorCard(context, state.message);
    }

    if (state is BluetoothDevicesFound ||
        state is BluetoothConnecting ||
        state is BluetoothConnected) {
      final devices = (state is BluetoothDevicesFound)
          ? state.devices
          : (state is BluetoothConnecting)
          ? [state.device]
          : (state is BluetoothConnected)
          ? [state.device]
          : [];

      final isScanning = (state is BluetoothDevicesFound)
          ? state.isScanning
          : false;

      if (devices.isEmpty) {
        return _emptyDevicesCard(context);
      }

      return Column(
        children: [
          _hardwareGuidanceBanner(context),
          SizedBox(height: 12.h),
          if (!isScanning && state is BluetoothDevicesFound)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan Finished',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMediumGrey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<BluetoothBloc>().add(
                      StartSearch(isWifiOnly: widget.isWifi),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16.w,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Scan Again',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index] as BluetoothDevice;
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _deviceCard(context, device, state),
                );
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _hardwareGuidanceBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = widget.isWifi
        ? 'Hardware tip: Connect your phone to your OBD-II adapter\'s Wi-Fi network in your device Wi-Fi settings.'
        : 'Hardware tip: Ensure your OBD-II scanner is plugged into the OBD port and ignition is switched ON.';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            widget.isWifi
                ? Icons.wifi_find_rounded
                : Icons.info_outline_rounded,
            size: 20.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDevicesCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modeName = widget.isWifi ? 'Wi-Fi' : 'Bluetooth';
    return Column(
      children: [
        _hardwareGuidanceBanner(context),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderColor,
            ),
          ),
          child: Column(
            children: [
              Icon(
                widget.isWifi
                    ? Icons.wifi_off_rounded
                    : Icons.bluetooth_searching_rounded,
                size: 48.w,
                color: AppColors.textMediumGrey,
              ),
              SizedBox(height: 16.h),
              Text(
                'No $modeName Devices Discovered',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textVeryDarkGrey,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.isWifi
                    ? 'Make sure your Wi-Fi OBD-II adapter is plugged into your vehicle and your phone is connected to the adapter\'s Wi-Fi network.'
                    : 'Make sure your OBD-II device is plugged in, powered on, and within range (10 meters).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMediumGrey,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => context.read<BluetoothBloc>().add(
                  StartSearch(isWifiOnly: widget.isWifi),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 18.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Rescan for Devices',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _permissionDeniedCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(top: 48.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderColor,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.bluetooth_disabled_rounded,
                  size: 48.w,
                  color: AppColors.textMediumGrey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Bluetooth Permission Denied',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textVeryDarkGrey,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please allow Bluetooth and Location access in your device settings to scan for OBD adapters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textMediumGrey,
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () => context.read<BluetoothBloc>().add(StartSearch()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(top: 48.h),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.w,
              color: AppColors.tertiaryRed,
            ),
            SizedBox(height: 16.h),
            Text(
              'Connection Failed',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textVeryDarkGrey,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textMediumGrey,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => context.read<BluetoothBloc>().add(StartSearch()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Retry Scan',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceCard(
    BuildContext context,
    BluetoothDevice device,
    BluetoothState state,
  ) {
    String status = 'Tap to connect';
    bool isConnecting = false;
    bool isConnected = false;

    if (state is BluetoothConnecting && state.device == device) {
      status = 'Connecting...';
      isConnecting = true;
    } else if (state is BluetoothConnected && state.device == device) {
      status = 'Connected';
      isConnected = true;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isConnecting
          ? null
          : () {
              if (!isConnected) {
                context.read<BluetoothBloc>().add(DeviceSelected(device));
              }
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isConnected
                ? AppColors.primary.withValues(alpha: 0.4)
                : (isDark ? AppColors.darkBorder : AppColors.borderColor),
            width: isConnected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: device.isWifi
                    ? const Color(0xFFEAF4FF)
                    : AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: device.isWifi
                  ? Icon(Icons.wifi_rounded, size: 22.w, color: AppColors.blue)
                  : SvgPicture.asset(Assets.bluetoothLightGrey),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: device.isWifi
                              ? const Color(0xFFEAF4FF)
                              : AppColors.fadedPrimary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          device.isWifi ? 'WiFi' : 'BLE',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: device.isWifi
                                ? AppColors.blue
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textMediumGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (device.isBle && device.rssi != null) ...[
                        SizedBox(width: 8.w),
                        _rssiIcon(device.rssi!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (isConnecting)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            else if (isConnected)
              SvgPicture.asset(Assets.checkCircleGrey)
            else
              SvgPicture.asset(Assets.arrowRight),
          ],
        ),
      ),
    );
  }

  Widget _rssiIcon(int rssi) {
    IconData icon;
    Color color;
    if (rssi >= -60) {
      icon = Icons.signal_wifi_4_bar_rounded;
      color = AppColors.green;
    } else if (rssi >= -75) {
      icon = Icons.network_wifi_3_bar_rounded;
      color = AppColors.yellow;
    } else {
      icon = Icons.network_wifi_1_bar_rounded;
      color = AppColors.tertiaryRed;
    }
    return Icon(icon, size: 16.w, color: color);
  }
}

class PulsatingDeviceIcon extends StatelessWidget {
  final bool isWifi;
  const PulsatingDeviceIcon({super.key, this.isWifi = false});

  static const double _centerSize = 88.0;

  Widget _ring({
    required double endScale,
    required double beginOpacity,
    required double endOpacity,
  }) {
    return Container(
          width: _centerSize.w,
          height: _centerSize.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(endScale, endScale),
          duration: 1600.ms,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: beginOpacity,
          end: endOpacity,
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _blinkingDot() {
    return Container(
          width: 3.w,
          height: 3.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .custom(
          duration: 2000.ms,
          builder: (ctx, value, child) {
            // value: 0.0 → 1.0 over 2000ms (no reverse)
            // Triple blink: on/off/on/off/on → long pause
            final ms = value * 2000;
            final opacity = (ms < 180)
                ? 1.0
                : (ms < 320)
                ? 0.0
                : (ms < 500)
                ? 1.0
                : (ms < 640)
                ? 0.0
                : (ms < 820)
                ? 1.0
                : 0.0;
            return Opacity(opacity: opacity, child: child);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180.w,
      height: 180.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring: scales to 1.75x, fades 0.25 → 0.65
          _ring(endScale: 1.75, beginOpacity: 0.2, endOpacity: 0.6),

          // Inner ring: scales to 1.42x, fades 0.3 → 1.0
          _ring(endScale: 1.42, beginOpacity: 0.3, endOpacity: 1.0),

          // Central filled circle
          Container(
            width: _centerSize.w,
            height: _centerSize.w,
            decoration: BoxDecoration(
              color: AppColors.fadedPrimary,
              shape: BoxShape.circle,
            ),
            // Stack icon + dots so dots are tightly overlapping the icon area
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Icon (Wi-Fi or Bluetooth)
                if (isWifi)
                  Icon(Icons.wifi_rounded, size: 36.w, color: AppColors.primary)
                else
                  SvgPicture.asset(Assets.bluetoothBlue),
                // Left dot — nudged left
                Transform.translate(
                  offset: Offset(-10.w, 0),
                  child: _blinkingDot(),
                ),
                // Right dot — nudged right
                Transform.translate(
                  offset: Offset(10.w, 0),
                  child: _blinkingDot(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
