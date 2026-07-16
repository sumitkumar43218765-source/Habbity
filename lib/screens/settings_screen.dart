import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings ⚙️'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildListTile(
                context,
                title: 'Dark Mode',
                icon: Icons.dark_mode,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
              );
            },
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Data'),
          _buildListTile(
            context,
            title: 'Export Data (CSV)',
            icon: Icons.file_download,
            onTap: () async {
              final provider = Provider.of<HabitProvider>(context, listen: false);
              final path = await ExportService.exportToCsv(provider.habits, provider.todayRecords); // Note: using todayRecords just as placeholder, proper implementation should export all
              ExportService.shareExport(path);
            },
          ).animate().fadeIn(delay: 100.ms).slideX(),
          _buildListTile(
            context,
            title: 'Reset All Data',
            icon: Icons.delete_forever,
            textColor: AppColors.error,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset All Data?'),
                  content: const Text('This will delete all your habits and records. This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Implement clear all logic via database service if possible
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data reset not fully implemented yet.')),
                        );
                      },
                      child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms).slideX(),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildListTile(
            context,
            title: 'App Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
          ).animate().fadeIn(delay: 300.ms).slideX(),
          
          const SizedBox(height: 48),
          Center(
            child: const Text(
              'Made with ❤️ by Sonu Kumar',
              style: TextStyle(color: AppColors.textSubtle),
            ).animate().fadeIn(delay: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: textColor ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
