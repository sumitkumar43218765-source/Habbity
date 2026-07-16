import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../models/category.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';
import '../utils/habit_icons.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? existingHabit;
  
  const AddHabitScreen({super.key, this.existingHabit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  
  String _selectedIcon = '🎯';
  int _selectedColor = AppColors.primary.value;
  String _selectedCategory = HabitCategory.personal.name;
  List<int> _selectedDays = []; // empty = daily
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingHabit?.name ?? '');
    _targetController = TextEditingController(text: widget.existingHabit?.targetDescription ?? '');
    
    if (widget.existingHabit != null) {
      _selectedIcon = widget.existingHabit!.icon;
      _selectedColor = widget.existingHabit!.colorValue;
      _selectedCategory = widget.existingHabit!.category;
      _selectedDays = List.from(widget.existingHabit!.frequencyDays);
      if (widget.existingHabit!.reminderTime != null) {
        final parts = widget.existingHabit!.reminderTime!.split(':');
        _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final String reminderStr = _reminderTime != null 
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : '';
          
      final newHabit = Habit(
        id: widget.existingHabit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        colorValue: _selectedColor,
        category: _selectedCategory,
        frequencyDays: _selectedDays,
        reminderTime: reminderStr.isEmpty ? null : reminderStr,
        targetDescription: _targetController.text.trim().isEmpty ? null : _targetController.text.trim(),
        createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
      );

      final provider = Provider.of<HabitProvider>(context, listen: false);
      if (widget.existingHabit != null) {
        provider.updateHabit(newHabit);
      } else {
        provider.addHabit(newHabit);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingHabit != null ? 'Edit Habit' : 'Create Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Read 30 minutes',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
            ).animate().fadeIn().slideX(),
            
            const SizedBox(height: 24),
            const Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: HabitIcons.icons.length,
                itemBuilder: (context, index) {
                  final icon = HabitIcons.icons[index];
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? Color(_selectedColor).withOpacity(0.2) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Color(_selectedColor) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(icon, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(),

            const SizedBox(height: 24),
            const Text('Choose Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.habitColors.length,
                itemBuilder: (context, index) {
                  final color = AppColors.habitColors[index];
                  final isSelected = _selectedColor == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(),
            
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              items: HabitCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat.name,
                  child: Row(
                    children: [
                      Text(cat.icon),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ).animate().fadeIn(delay: 300.ms).slideX(),

            const SizedBox(height: 24),
            const Text('Frequency (Leave empty for Daily)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 1; i <= 7; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedDays.contains(i)) {
                          _selectedDays.remove(i);
                        } else {
                          _selectedDays.add(i);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedDays.contains(i) ? Color(_selectedColor) : Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        ['M','T','W','T','F','S','S'][i-1],
                        style: TextStyle(
                          color: _selectedDays.contains(i) ? Colors.white : AppColors.textSubtle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideX(),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(_selectedColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Habit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}
