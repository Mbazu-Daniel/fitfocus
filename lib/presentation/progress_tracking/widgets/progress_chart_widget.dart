import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressChartWidget extends StatelessWidget {
  final String title;
  final String chartType;
  final List<Map<String, dynamic>> data;
  final VoidCallback? onTap;

  const ProgressChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            if (onTap != null)
              GestureDetector(
                  onTap: onTap,
                  child: CustomIconWidget(
                      iconName: 'more_horiz',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20)),
          ]),
          SizedBox(height: 3.h),
          SizedBox(height: 30.h, child: _buildChart(context, chartType)),
        ]));
  }

  Widget _buildChart(BuildContext context, String type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (type) {
      case 'bar':
        return _buildBarChart(context);
      case 'pie':
        return _buildPieChart(context);
      case 'line':
        return _buildLineChart(context);
      default:
        return _buildBarChart(context);
    }
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isNotEmpty
            ? (data
                    .map((e) => (e['value'] as num).toDouble())
                    .reduce((a, b) => a > b ? a : b) *
                1.2)
            : 10,
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                      '${data[group.x.toInt()]['label']}\n${rod.toY.round()}',
                      theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onInverseSurface,
                              fontWeight: FontWeight.w500) ??
                          const TextStyle());
                })),
        titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(data[value.toInt()]['label'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6))));
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6)));
                    }))),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
                toY: (item['value'] as num).toDouble(),
                color: colorScheme.primary,
                width: 6.w,
                borderRadius: BorderRadius.circular(4)),
          ]);
        }).toList()));
  }

  Widget _buildPieChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final colors = [
      colorScheme.primary,
      AppTheme.secondaryLight,
      AppTheme.accentLight,
      AppTheme.warningLight,
      AppTheme.successLight,
    ];

    return PieChart(PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 8.w,
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = colors[index % colors.length];

          return PieChartSectionData(
              color: color,
              value: (item['value'] as num).toDouble(),
              title: '${item['percentage']}%',
              radius: 12.w,
              titleStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600));
        }).toList(),
        pieTouchData:
            PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
          // Handle touch interactions
        })));
  }

  Widget _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LineChart(LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  strokeWidth: 1);
            }),
        titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(data[value.toInt()]['label'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6))));
                      }
                      return const SizedBox.shrink();
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6)));
                    }))),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(),
                    (entry.value['value'] as num).toDouble());
              }).toList(),
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                        radius: 4,
                        color: colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: colorScheme.surface);
                  }),
              belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.primary.withValues(alpha: 0.1))),
        ],
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    return LineTooltipItem(
                        '${data[flSpot.x.toInt()]['label']}\n${flSpot.y.round()}',
                        theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w500) ??
                            const TextStyle());
                  }).toList();
                }))));
  }
}
