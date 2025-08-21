import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback? onVoiceSearch;
  final List<String> recentSearches;
  final Function(String)? onRecentSearchTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.onVoiceSearch,
    this.recentSearches = const [],
    this.onRecentSearchTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _showRecentSearches = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showRecentSearches =
            _focusNode.hasFocus && widget.recentSearches.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 4.w),
              CustomIconWidget(
                iconName: 'search',
                size: 5.w,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: CustomIconWidget(
                      iconName: 'clear',
                      size: 5.w,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (widget.onVoiceSearch != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onVoiceSearch?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: CustomIconWidget(
                      iconName: 'mic',
                      size: 5.w,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onFilterTap();
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  margin: EdgeInsets.only(right: 2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'tune',
                    size: 5.w,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showRecentSearches) _buildRecentSearches(theme),
      ],
    );
  }

  Widget _buildRecentSearches(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                size: 4.w,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recent Searches',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...widget.recentSearches
              .take(5)
              .map(
                (search) => GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onRecentSearchTap?.call(search);
                    _focusNode.unfocus();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'search',
                          size: 4.w,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            search,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'north_west',
                          size: 4.w,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
