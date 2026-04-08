import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/config/issue_database.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

/// Shared tag for the Hero animation between HomeScreen and CodeSearchScreen.
const String kInputCodeHeroTag = 'input-code-field';

class CodeSearchScreen extends StatefulWidget {
  const CodeSearchScreen({super.key});

  @override
  State<CodeSearchScreen> createState() => _CodeSearchScreenState();
}

class _CodeSearchScreenState extends State<CodeSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const _recentSearches = [
    ('P0A01', 'Drive Motor A Inverter Performance'),
    ('P0001', 'Fuel Volume Regulator Control Circuit/Open'),
    ('B1365', 'Ignition Start Circuit Failure'),
    ('C0074', 'ABS Brake Pressure Sensor Circuit'),
  ];

  @override
  void initState() {
    super.initState();
    // Request focus after the Hero flight completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // ── Hero search bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                      color: AppColors.secondaryTxtField,
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

            SizedBox(height: 20.h),

            // ── Recent searches header ───────────────────────────────────
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

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final (code, description) = _recentSearches[index];
                  return _searchItem(code, description);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _searchItem(String code, String description) {
    return InkWell(
      onTap: () {
        final issue = IssueDatabase.getIssue(code);
        if (issue != null) {
          context.pushNamed(AppRoutes.issueDetail, extra: issue);
        } else {
          _controller.text = code;
          _focusNode.unfocus();
        }
      },
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
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
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
          ],
        ),
      ),
    );
  }
}
