import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/exercise_card_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/search_bar_widget.dart';

class ExerciseLibrary extends StatefulWidget {
  const ExerciseLibrary({super.key});

  @override
  State<ExerciseLibrary> createState() => _ExerciseLibraryState();
}

class _ExerciseLibraryState extends State<ExerciseLibrary>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  bool _isRefreshing = false;
  bool _isOffline = false;

  late AnimationController _staggerAnimationController;
  late List<Animation<Offset>> _slideAnimations;

  final List<String> _categories = [
    'All',
    'Stretching',
    'Cardio',
    'Strength',
    'Eye Exercises'
  ];

  final List<String> _recentSearches = [
    'neck stretches',
    'desk exercises',
    'eye strain relief',
    'back pain',
    'quick cardio'
  ];

  final List<Map<String, dynamic>> _allExercises = [
    {
      "id": 1,
      "name": "Neck Roll Stretch",
      "category": "Stretching",
      "duration": 2,
      "difficulty": "Beginner",
      "equipment": "No Equipment",
      "bodyFocus": "Neck & Shoulders",
      "gifUrl":
          "https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Gentle neck rolls to relieve tension and improve flexibility in the neck and shoulder area."
    },
    {
      "id": 2,
      "name": "Desk Push-ups",
      "category": "Strength",
      "duration": 3,
      "difficulty": "Intermediate",
      "equipment": "Desk",
      "bodyFocus": "Arms",
      "gifUrl":
          "https://images.pexels.com/photos/4162449/pexels-photo-4162449.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": true,
      "description":
          "Modified push-ups using your desk to strengthen arms and chest muscles."
    },
    {
      "id": 3,
      "name": "Seated Spinal Twist",
      "category": "Stretching",
      "duration": 2,
      "difficulty": "Beginner",
      "equipment": "Chair",
      "bodyFocus": "Back",
      "gifUrl":
          "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Gentle spinal rotation to improve back flexibility and reduce stiffness."
    },
    {
      "id": 4,
      "name": "Eye Focus Exercise",
      "category": "Eye Exercises",
      "duration": 1,
      "difficulty": "Beginner",
      "equipment": "No Equipment",
      "bodyFocus": "Eyes",
      "gifUrl":
          "https://images.pexels.com/photos/5473298/pexels-photo-5473298.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Simple eye movements to reduce digital eye strain and improve focus."
    },
    {
      "id": 5,
      "name": "Chair Squats",
      "category": "Strength",
      "duration": 3,
      "difficulty": "Intermediate",
      "equipment": "Chair",
      "bodyFocus": "Legs",
      "gifUrl":
          "https://images.pexels.com/photos/4162492/pexels-photo-4162492.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": true,
      "description":
          "Strengthen your leg muscles with chair-assisted squats perfect for office breaks."
    },
    {
      "id": 6,
      "name": "Shoulder Blade Squeeze",
      "category": "Stretching",
      "duration": 2,
      "difficulty": "Beginner",
      "equipment": "No Equipment",
      "bodyFocus": "Back",
      "gifUrl":
          "https://images.pexels.com/photos/4498606/pexels-photo-4498606.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Improve posture and reduce upper back tension with shoulder blade squeezes."
    },
    {
      "id": 7,
      "name": "Desk Cardio Burst",
      "category": "Cardio",
      "duration": 5,
      "difficulty": "Intermediate",
      "equipment": "No Equipment",
      "bodyFocus": "Full Body",
      "gifUrl":
          "https://images.pexels.com/photos/4162438/pexels-photo-4162438.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Quick cardio routine to boost energy and circulation during work breaks."
    },
    {
      "id": 8,
      "name": "Wrist Circles",
      "category": "Stretching",
      "duration": 1,
      "difficulty": "Beginner",
      "equipment": "No Equipment",
      "bodyFocus": "Arms",
      "gifUrl":
          "https://images.pexels.com/photos/4498151/pexels-photo-4498151.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isFavorite": false,
      "description":
          "Prevent wrist strain and improve flexibility with gentle wrist rotations."
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();
  }

  void _initializeAnimations() {
    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimations = List.generate(
      6,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerAnimationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _staggerAnimationController.forward();
  }

  void _checkConnectivity() {
    // Simulate connectivity check
    setState(() {
      _isOffline = false; // In real app, use connectivity_plus package
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _staggerAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredExercises {
    List<Map<String, dynamic>> filtered = _allExercises;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((exercise) => exercise['category'] == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((exercise) =>
              (exercise['name'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (exercise['category'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (exercise['bodyFocus'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply advanced filters
    if (_activeFilters.isNotEmpty) {
      if (_activeFilters.containsKey('difficulty')) {
        filtered = filtered
            .where((exercise) =>
                exercise['difficulty'] == _activeFilters['difficulty'])
            .toList();
      }

      if (_activeFilters.containsKey('duration')) {
        final durationFilter = _activeFilters['duration'] as String;
        filtered = filtered.where((exercise) {
          final duration = exercise['duration'] as int;
          switch (durationFilter) {
            case '1-5 min':
              return duration >= 1 && duration <= 5;
            case '5-10 min':
              return duration > 5 && duration <= 10;
            case '10-15 min':
              return duration > 10 && duration <= 15;
            case '15+ min':
              return duration > 15;
            default:
              return true;
          }
        }).toList();
      }

      if (_activeFilters.containsKey('equipment')) {
        final equipmentList = _activeFilters['equipment'] as List<String>;
        filtered = filtered
            .where((exercise) => equipmentList.contains(exercise['equipment']))
            .toList();
      }

      if (_activeFilters.containsKey('bodyFocus')) {
        final bodyFocusList = _activeFilters['bodyFocus'] as List<String>;
        filtered = filtered
            .where((exercise) => bodyFocusList.contains(exercise['bodyFocus']))
            .toList();
      }
    }

    return filtered;
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise library updated!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _handleCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
          });
        },
      ),
    );
  }

  void _handleExerciseTap(Map<String, dynamic> exercise) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/exercise-detail',
      arguments: exercise,
    );
  }

  void _handleFavoriteToggle(Map<String, dynamic> exercise) {
    HapticFeedback.lightImpact();
    setState(() {
      exercise['isFavorite'] = !(exercise['isFavorite'] as bool? ?? false);
    });

    final message = (exercise['isFavorite'] as bool)
        ? 'Added to favorites'
        : 'Removed from favorites';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleShare(Map<String, dynamic> exercise) {
    HapticFeedback.lightImpact();
    // In real app, implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${exercise["name"]}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleAddToRoutine(Map<String, dynamic> exercise) {
    HapticFeedback.lightImpact();
    // In real app, implement add to routine functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise["name"]} added to custom routine'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleVoiceSearch() {
    HapticFeedback.lightImpact();
    // In real app, implement voice search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice search not available'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleRecentSearchTap(String search) {
    _searchController.text = search;
    _handleSearch(search);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _searchQuery = '';
      _activeFilters.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredExercises = _filteredExercises;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Exercise Library',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (_isOffline)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: CustomIconWidget(
                iconName: 'cloud_off',
                size: 6.w,
                color: colorScheme.error,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(4.w),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: _handleSearch,
                onFilterTap: _showFilterModal,
                onVoiceSearch: _handleVoiceSearch,
                recentSearches: _recentSearches,
                onRecentSearchTap: _handleRecentSearchTap,
              ),
            ),

            // Filter Chips
            Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return FilterChipWidget(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () => _handleCategoryFilter(category),
                    iconName: _getCategoryIcon(category),
                  );
                },
              ),
            ),

            // Active Filters Indicator
            if (_activeFilters.isNotEmpty || _searchQuery.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Text(
                      '${filteredExercises.length} exercises found',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear All',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Exercise Grid
            Expanded(
              child: filteredExercises.isEmpty
                  ? EmptyStateWidget(
                      title:
                          _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                              ? 'No exercises found'
                              : 'No exercises available',
                      subtitle: _searchQuery.isNotEmpty ||
                              _activeFilters.isNotEmpty
                          ? 'Try adjusting your search or filters to find more exercises.'
                          : 'Check your connection and pull to refresh, or browse our exercise categories.',
                      buttonText:
                          _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                              ? 'Clear Filters'
                              : 'Browse All Exercises',
                      onButtonPressed:
                          _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                              ? _clearFilters
                              : _handleRefresh,
                      illustrationUrl:
                          'https://images.pexels.com/photos/4162438/pexels-photo-4162438.jpeg?auto=compress&cs=tinysrgb&w=400',
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: colorScheme.primary,
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(4.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 3.w,
                        ),
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          final animationIndex = index < _slideAnimations.length
                              ? index
                              : _slideAnimations.length - 1;

                          return SlideTransition(
                            position: _slideAnimations[animationIndex],
                            child: ExerciseCardWidget(
                              exercise: exercise,
                              onTap: () => _handleExerciseTap(exercise),
                              onFavoriteToggle: () =>
                                  _handleFavoriteToggle(exercise),
                              onShare: () => _handleShare(exercise),
                              onAddToRoutine: () =>
                                  _handleAddToRoutine(exercise),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getCategoryIcon(String category) {
    switch (category) {
      case 'Stretching':
        return 'accessibility_new';
      case 'Cardio':
        return 'favorite';
      case 'Strength':
        return 'fitness_center';
      case 'Eye Exercises':
        return 'visibility';
      default:
        return null;
    }
  }
}
