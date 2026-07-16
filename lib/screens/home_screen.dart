import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';
import '../utils/constants.dart';
import '../theme/app_colors.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_bottom_nav.dart';
import '../models/category.dart';

import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              _HomeTab(),
              StatsScreen(),
              SettingsScreen(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: AppColors.habitColors,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final habits = provider.todayHabits;
        if (provider.selectedCategory != null) {
          habits.retainWhere((h) => h.category == provider.selectedCategory);
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppDateUtils.getGreeting()}! 👋',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatDate(DateTime.now()),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSubtle,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                        const SizedBox(height: 24),
                        Center(
                          child: ProgressRing(
                            progress: provider.todayProgress,
                            completed: provider.todayCompleted,
                            total: provider.todayTotal,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryChip(
                        label: 'All',
                        emoji: '📱',
                        isSelected: provider.selectedCategory == null,
                        onTap: () => provider.setCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...HabitCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryChip(
                            label: category.label,
                            emoji: category.icon,
                            isSelected: provider.selectedCategory == category.name,
                            onTap: () => provider.setCategory(category.name),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),
            ),
            if (habits.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        provider.selectedCategory == null
                            ? 'No habits for today.\nAdd your first habit!'
                            : 'No habits in this category today.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habits[index];
                      final isCompleted = provider.isHabitCompletedOn(habit.id, DateTime.now());
                      final streak = provider.getCurrentStreak(habit.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: HabitCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          streak: streak,
                          onTap: () {
                            provider.toggleHabitCompletion(habit.id, DateTime.now());
                            if (!isCompleted && provider.todayCompleted + 1 == provider.todayTotal) {
                              // Trigger confetti if this is the last habit
                              final state = context.findAncestorStateOfType<_HomeScreenState>();
                              state?._confettiController.play();
                            }
                          },
                          onLongPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HabitDetailScreen(habit: habit),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.2);
                    },
                    childCount: habits.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
