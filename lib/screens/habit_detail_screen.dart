import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final habitColor = Color(habit.colorValue);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddHabitScreen(existingHabit: habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit?'),
                  content: Text('Are you sure you want to delete "${habit.name}"? All history will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // close screen
                      },
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          // Get updated habit instance if it changed
          final currentHabit = provider.habits.firstWhere((h) => h.id == habit.id, orElse: () => habit);
          
          final streak = provider.getCurrentStreak(currentHabit.id);
          final bestStreak = provider.getBestStreak(currentHabit.id);
          final completionRate = provider.getCompletionRate(currentHabit.id);
          final totalRecords = provider.getHabitRecords(currentHabit.id).where((r) => r.isCompleted).length;
          
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: habitColor, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(currentHabit.icon, style: const TextStyle(fontSize: 48)),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  currentHabit.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms).slideY(),
              ),
              if (currentHabit.targetDescription != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    currentHabit.targetDescription!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
                  ).animate().fadeIn(delay: 200.ms),
                ),
              ],
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Current Streak',
                      value: '$streak 🔥',
                      icon: Icons.local_fire_department,
                      color: habitColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Best Streak',
                      value: '$bestStreak 🏆',
                      icon: Icons.emoji_events,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Completion Rate',
                      value: '${(completionRate * 100).toInt()}%',
                      icon: Icons.pie_chart,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Total Done',
                      value: totalRecords.toString(),
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Category', currentHabit.category.toUpperCase(), Icons.category),
                    _buildDetailRow('Created', DateFormat.yMMMd().format(currentHabit.createdAt), Icons.calendar_today),
                    _buildDetailRow('Frequency', currentHabit.frequencyDays.isEmpty ? 'Daily' : '${currentHabit.frequencyDays.length} days/week', Icons.repeat),
                    if (currentHabit.reminderTime != null)
                      _buildDetailRow('Reminder', currentHabit.reminderTime!, Icons.notifications_active),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSubtle),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSubtle)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
