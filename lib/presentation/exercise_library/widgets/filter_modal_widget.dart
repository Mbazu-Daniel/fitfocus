import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModalWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  final List<String> _durations = [
    '1-5 min',
    '5-10 min',
    '10-15 min',
    '15+ min'
  ];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _equipment = [
    'No Equipment',
    'Chair',
    'Desk',
    'Resistance Band',
    'Dumbbells'
  ];
  final List<String> _bodyFocus = [
    'Neck & Shoulders',
    'Back',
    'Arms',
    'Core',
    'Legs',
    'Eyes',
    'Full Body'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: CustomIconWidget(
                    iconName: 'close',
                    size: 6.w,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Filter Exercises',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _filters.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Duration',
                    _durations,
                    'duration',
                    theme,
                    multiSelect: false,
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Difficulty Level',
                    _difficulties,
                    'difficulty',
                    theme,
                    multiSelect: false,
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Equipment Needed',
                    _equipment,
                    'equipment',
                    theme,
                    multiSelect: true,
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Body Focus Areas',
                    _bodyFocus,
                    'bodyFocus',
                    theme,
                    multiSelect: true,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String filterKey,
    ThemeData theme, {
    bool multiSelect = false,
  }) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = multiSelect
                ? (_filters[filterKey] as List<String>? ?? []).contains(option)
                : _filters[filterKey] == option;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (multiSelect) {
                    final currentList =
                        (_filters[filterKey] as List<String>? ?? []);
                    if (isSelected) {
                      currentList.remove(option);
                      if (currentList.isEmpty) {
                        _filters.remove(filterKey);
                      } else {
                        _filters[filterKey] = currentList;
                      }
                    } else {
                      _filters[filterKey] = [...currentList, option];
                    }
                  } else {
                    if (isSelected) {
                      _filters.remove(filterKey);
                    } else {
                      _filters[filterKey] = option;
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
