import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ExerciseTabsWidget extends StatefulWidget {
  final List<String> instructions;
  final List<String> benefits;
  final List<String> equipment;

  const ExerciseTabsWidget({
    super.key,
    required this.instructions,
    required this.benefits,
    required this.equipment,
  });

  @override
  State<ExerciseTabsWidget> createState() => _ExerciseTabsWidgetState();
}

class _ExerciseTabsWidgetState extends State<ExerciseTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.all(2),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
              tabs: [
                Tab(text: 'Instructions'),
                Tab(text: 'Benefits'),
                Tab(text: 'Equipment'),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Tab content
          Container(
            height: 35.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstructionsTab(),
                _buildBenefitsTab(),
                _buildEquipmentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        itemCount: widget.instructions.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Instruction text
                Expanded(
                  child: Text(
                    widget.instructions[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        itemCount: widget.benefits.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Benefit icon
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.successLight,
                    size: 5.w,
                  ),
                ),

                SizedBox(width: 3.w),

                // Benefit text
                Expanded(
                  child: Text(
                    widget.benefits[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: widget.equipment.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'fitness_center',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    size: 15.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No Equipment Needed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 16.sp,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'This exercise can be performed with just your body weight',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 12.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: widget.equipment.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Equipment icon
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'fitness_center',
                          color: AppTheme.accentLight,
                          size: 5.w,
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Equipment name
                      Expanded(
                        child: Text(
                          widget.equipment[index],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
