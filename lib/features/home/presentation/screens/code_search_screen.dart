import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/obd_service.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

/// Shared tag for the Hero animation between HomeScreen and CodeSearchScreen.
const String kInputCodeHeroTag = 'input-code-field';

class CodeSearchScreen extends StatefulWidget {
  final String? initialSearchQuery;
  const CodeSearchScreen({super.key, this.initialSearchQuery});

  @override
  State<CodeSearchScreen> createState() => _CodeSearchScreenState();
}

class _CodeSearchScreenState extends State<CodeSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  Timer? _debounce;
  List<ObdSearchResult> _searchResults = [];
  bool _isLoading = false;
  List<ObdHistoryItem> _dynamicRecentSearches = [];

  static const _recentSearches = [
    ('P0A01', 'Drive Motor A Inverter Performance'),
    ('P0001', 'Fuel Volume Regulator Control Circuit/Open'),
    ('B1365', 'Ignition Start Circuit Failure'),
    ('C0074', 'ABS Brake Pressure Sensor Circuit'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.initialSearchQuery != null) {
      _controller.text = widget.initialSearchQuery!;
      _performSearch(widget.initialSearchQuery!);
    }
    _controller.addListener(() {
      _onSearchChanged(_controller.text);
    });
    // Request focus after the Hero flight completes (route transition finishes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.animation != null) {
        route.animation!.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (mounted) _focusNode.requestFocus();
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _focusNode.requestFocus();
        });
      }
    });
  }

  Future<void> _loadSearchHistory() async {
    try {
      final obdService = context.read<ObdService>();
      final history = await obdService.getSearchHistory(limit: 50);
      if (mounted) {
        setState(() {
          _dynamicRecentSearches = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final obdService = context.read<ObdService>();
      final results = await obdService.searchCodes(cleanQuery);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onResultTapped(String code) {
    if (mounted) {
      context.pushNamed(AppRoutes.issueDetail, extra: code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String query = _controller.text.trim();
    final bool hasQuery = query.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // ── Hero search bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Hero(
                tag: kInputCodeHeroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryTxtFieldBg,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      children: [
                        // Back button inside the pill
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                            ).copyWith(right: 12.w),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.hintGrey,
                              size: 22.sp,
                            ),
                          ),
                        ),
                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              hintText: 'Input code',
                              hintStyle: TextStyle(
                                color: AppColors.hintGrey,
                                fontSize: 15.sp,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textVeryDarkGrey,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Selective Animation for Content ──────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasQuery) ...[
                    SizedBox(height: 20.h),
                    // ── Recent searches header ─────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'MANAGE HISTORY',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ] else ...[
                    SizedBox(height: 12.h),
                  ],

                  // ── List / Loader ───────────────────────────────────────────────
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : hasQuery && _searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  'No results found for "$query"',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.textMediumGrey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                itemCount: hasQuery
                                    ? _searchResults.length
                                    : (_dynamicRecentSearches.isNotEmpty
                                        ? _dynamicRecentSearches.length
                                        : _recentSearches.length),
                                itemBuilder: (context, index) {
                                  if (hasQuery) {
                                    final result = _searchResults[index];
                                    return _searchItem(
                                      result.code,
                                      result.faultDescription.isNotEmpty
                                          ? result.faultDescription
                                          : result.primaryCause,
                                      isRecent: false,
                                      priority: result.priority,
                                    );
                                  } else {
                                    if (_dynamicRecentSearches.isNotEmpty) {
                                      final item = _dynamicRecentSearches[index];
                                      return _searchItem(
                                        item.query,
                                        'Search Type: ${item.searchType}',
                                        isRecent: true,
                                      );
                                    } else {
                                      final (code, description) =
                                          _recentSearches[index];
                                      return _searchItem(
                                        code,
                                        description,
                                        isRecent: true,
                                      );
                                    }
                                  }
                                },
                              ),
                  ),
                ],
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchItem(
    String code,
    String description, {
    required bool isRecent,
    String? priority,
  }) {
    DiagnosticSeverity? severity;
    if (priority != null) {
      switch (priority.toLowerCase()) {
        case 'critical':
        case 'high':
          severity = DiagnosticSeverity.critical;
          break;
        case 'warning':
        case 'medium':
          severity = DiagnosticSeverity.warning;
          break;
        case 'info':
        case 'low':
        default:
          severity = DiagnosticSeverity.info;
      }
    }

    return InkWell(
      onTap: () => _onResultTapped(code),
      splashColor: AppColors.primaryDisabled.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(Assets.recentSearches),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      if (severity != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: severity.bgColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            severity.label == 'HIGH'
                                ? 'CRITICAL'
                                : severity.label.toUpperCase(),
                            style: TextStyle(
                              color: severity.color,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: AppColors.black400,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(Assets.arrowRight),
          ],
        ),
      ),
    );
  }
}
