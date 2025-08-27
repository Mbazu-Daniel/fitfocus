import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/exercise_recommendation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../workout_session/workout_session_screen.dart';

class ExerciseBrowserScreen extends StatefulWidget {
  const ExerciseBrowserScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseBrowserScreen> createState() => _ExerciseBrowserScreenState();
}

class _ExerciseBrowserScreenState extends State<ExerciseBrowserScreen>
    with TickerProviderStateMixin {
  late AnimationController _filterController;
  late Animation<double> _filterAnimation;
  
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _searchQuery = '';
  bool _showFilters = false;
  
  List<Map<String, dynamic>> _allExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  List<Map<String, dynamic>> _selectedExercises = [];
  
  final List<String> _categories = ['All', 'Strength', 'Cardio', 'Flexibility', 'Posture', 'Relaxation'];
  final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _focusAreas = ['All', 'Posture Help', 'Stress Relief', 'Energy Boost'];
  
  String _selectedFocus = 'All';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExercises();
  }

  void _initializeAnimations() {
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadExercises() {
    _allExercises = ExerciseRecommendationService.instance.getAllExercises();
    _filterExercises();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final nameMatch = exercise['name'].toString().toLowerCase().contains(searchLower);
          final descriptionMatch = exercise['description'].toString().toLowerCase().contains(searchLower);
          final muscleMatch = (exercise['targetMuscles'] as List).any(
            (muscle) => muscle.toString().toLowerCase().contains(searchLower)
          );
          
          if (!nameMatch && !descriptionMatch && !muscleMatch) {
            return false;
          }
        }
        
        // Category filter
        if (_selectedCategory != 'All' && exercise['category'] != _selectedCategory) {
          return false;
        }
        
        // Difficulty filter
        if (_selectedDifficulty != 'All' && exercise['difficulty'] != _selectedDifficulty) {
          return false;
        }
        
        // Focus area filter
        if (_selectedFocus != 'All') {
          switch (_selectedFocus) {
            case 'Posture Help':
              if (exercise['postureHelp'] != true) return false;
              break;
            case 'Stress Relief':
              if (exercise['stressRelief'] != true) return false;
              break;
            case 'Energy Boost':
              if (exercise['category'] != 'Cardio') return false;
              break;
          }
        }
        
        return true;
      }).toList();
    });
  }

  void _toggleExerciseSelection(Map<String, dynamic> exercise) {
    setState(() {
      if (_selectedExercises.any((ex) => ex['id'] == exercise['id'])) {
        _selectedExercises.removeWhere((ex) => ex['id'] == exercise['id']);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  void _startSelectedWorkout() {
    if (_selectedExercises.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomWorkoutSessionScreen(exercises: _selectedExercises),
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedExercises.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Exercise Library',
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
              if (_showFilters) {
                _filterController.forward();
              } else {
                _filterController.reverse();
              }
            },
          ),
          if (_selectedExercises.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${_selectedExercises.length}'),
                child: Icon(Icons.playlist_play),
              ),
              onPressed: _startSelectedWorkout,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterExercises();
              },
              decoration: InputDecoration(
                hintText: 'Search exercises, muscles, or descriptions...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterExercises();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Filter section
          AnimatedBuilder(
            animation: _filterAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _filterAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _buildFilterSection(),
                ),
              );
            },
          ),
          
          // Results summary
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredExercises.length} exercises found',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedExercises.isNotEmpty)
                  Text(
                    '${_selectedExercises.length} selected',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // Exercise list
          Expanded(
            child: _filteredExercises.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      final isSelected = _selectedExercises.any((ex) => ex['id'] == exercise['id']);
                      return _buildExerciseCard(exercise, isSelected);
                    },
                  ),
          ),
        ],
      ),
      
      // Floating action buttons
      floatingActionButton: _selectedExercises.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'start',
                  onPressed: _startSelectedWorkout,
                  child: Icon(Icons.play_arrow),
                  backgroundColor: Colors.green,
                ),
                SizedBox(height: 2.h),
                FloatingActionButton(
                  heroTag: 'clear',
                  onPressed: _clearSelection,
                  child: Icon(Icons.clear),
                  backgroundColor: Colors.red,
                  mini: true,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          
          // Category filter
          Text(
            'Category',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _categories.map((category) => 
              FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _filterExercises();
                },
              ),
            ).toList(),
          ),
          
          SizedBox(height: 2.h),
          
          // Difficulty filter
          Text(
            'Difficulty',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _difficulties.map((difficulty) => 
              FilterChip(
                label: Text(difficulty),
                selected: _selectedDifficulty == difficulty,
                onSelected: (selected) {
                  setState(() {
                    _selectedDifficulty = difficulty;
                  });
                  _filterExercises();
                },
              ),
            ).toList(),
          ),
          
          SizedBox(height: 2.h),
          
          // Focus area filter
          Text(
            'Focus Area',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _focusAreas.map((focus) => 
              FilterChip(
                label: Text(focus),
                selected: _selectedFocus == focus,
                onSelected: (selected) {
                  setState(() {
                    _selectedFocus = focus;
                  });
                  _filterExercises();
                },
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No exercises found',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _toggleExerciseSelection(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(exercise['category']).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(exercise['category']),
                      color: _getCategoryColor(exercise['category']),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${exercise['category']} • ${exercise['difficulty']}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  
                  // Feature badges
                  Row(
                    children: [
                      if (exercise['postureHelp'] == true)
                        Container(
                          margin: EdgeInsets.only(left: 1.w),
                          child: Icon(Icons.accessibility_new, color: Colors.green, size: 16),
                        ),
                      if (exercise['stressRelief'] == true)
                        Container(
                          margin: EdgeInsets.only(left: 1.w),
                          child: Icon(Icons.self_improvement, color: Colors.blue, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              Text(
                exercise['description'],
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Exercise metrics
              Row(
                children: [
                  _buildMetricChip(Icons.timer, '${exercise['duration']}s', Colors.blue),
                  SizedBox(width: 2.w),
                  _buildMetricChip(Icons.repeat, '${exercise['sets']}×${exercise['reps']}', Colors.orange),
                  SizedBox(width: 2.w),
                  _buildMetricChip(Icons.local_fire_department, '${exercise['caloriesBurn']} cal', Colors.red),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              // Target muscles
              Wrap(
                spacing: 1.w,
                children: (exercise['targetMuscles'] as List).map((muscle) => 
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      muscle.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 1.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Colors.red;
      case 'cardio':
        return Colors.orange;
      case 'flexibility':
        return Colors.green;
      case 'posture':
        return Colors.blue;
      case 'relaxation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.favorite;
      case 'flexibility':
        return Icons.accessibility_new;
      case 'posture':
        return Icons.straighten;
      case 'relaxation':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
}

// Simplified custom workout session screen
class CustomWorkoutSessionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  
  const CustomWorkoutSessionScreen({Key? key, required this.exercises}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now, redirect to the main workout session screen
    // In a full implementation, this would create a custom session with the selected exercises
    return WorkoutSessionScreen();
  }
}