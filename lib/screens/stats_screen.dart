import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/stats_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/calendar_heatmap.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics 📊'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<StatsProvider>(
        builder: (context, stats, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Completions',
                      value: stats.totalCompletions.toString(),
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Longest Streak',
                      value: '${stats.longestStreak} 🔥',
                      icon: Icons.local_fire_department,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Active Streaks',
                      value: stats.activeStreaks.toString(),
                      icon: Icons.trending_up,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'This Week',
                      value: '${(stats.weeklyCompletionRate * 100).toInt()}%',
                      icon: Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 32),
              Text(
                'Activity Heatmap',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CalendarHeatmap(
                  data: stats.heatmapData,
                  months: 3,
                ),
              ).animate().fadeIn(delay: 300.ms).scale(),

              const SizedBox(height: 32),
              Text(
                'This Week',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            if (value >= 0 && value < 7) {
                              return Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSubtle));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: stats.weeklyData[i + 1] ?? 0,
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            ],
          );
        },
      ),
    );
  }
}
