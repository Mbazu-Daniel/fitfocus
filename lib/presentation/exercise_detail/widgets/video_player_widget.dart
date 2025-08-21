import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String exerciseTitle;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.exerciseTitle,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Video placeholder with thumbnail
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.videoUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay for better control visibility
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // Video controls
          if (_showControls) ...[
            // Center play/pause button
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: _isPlaying ? 'pause' : 'play_arrow',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Text(
                          _formatDuration(
                              _progress * 180), // Assuming 3 min video
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor:
                                  AppTheme.lightTheme.primaryColor,
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.3),
                              thumbColor: AppTheme.lightTheme.primaryColor,
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (value) {
                                setState(() {
                                  _progress = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "3:00",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildControlButton('replay_10', () {}),
                            SizedBox(width: 4.w),
                            _buildControlButton('forward_10', () {}),
                          ],
                        ),
                        Row(
                          children: [
                            _buildControlButton('volume_up', () {}),
                            SizedBox(width: 4.w),
                            _buildControlButton('fullscreen', () {}),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Tap to show/hide controls
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        child: CustomIconWidget(
          iconName: iconName,
          color: Colors.white,
          size: 5.w,
        ),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    // Simulate video progress when playing
    if (_isPlaying) {
      _simulateProgress();
    }
  }

  void _simulateProgress() {
    if (_isPlaying && _progress < 1.0) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted && _isPlaying) {
          setState(() {
            _progress += 0.001;
          });
          _simulateProgress();
        }
      });
    }
  }

  String _formatDuration(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
