/// Predefined categories that a habit can belong to.
///
/// Each category carries a human-readable [label] and a representative
/// emoji [icon] via the [HabitCategoryExtension].
enum HabitCategory {
  health,
  fitness,
  study,
  work,
  personal,
  mindfulness,
  nutrition,
  creativity,
  social,
  custom,
}

/// Convenience getters for display-friendly names and emoji icons.
extension HabitCategoryExtension on HabitCategory {
  /// A capitalised display name suitable for UI labels.
  String get label {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.study:
        return 'Study';
      case HabitCategory.work:
        return 'Work';
      case HabitCategory.personal:
        return 'Personal';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.nutrition:
        return 'Nutrition';
      case HabitCategory.creativity:
        return 'Creativity';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.custom:
        return 'Custom';
    }
  }

  /// An emoji that visually represents the category.
  String get icon {
    switch (this) {
      case HabitCategory.health:
        return '❤️';
      case HabitCategory.fitness:
        return '💪';
      case HabitCategory.study:
        return '📖';
      case HabitCategory.work:
        return '💼';
      case HabitCategory.personal:
        return '🌟';
      case HabitCategory.mindfulness:
        return '🧘';
      case HabitCategory.nutrition:
        return '🥗';
      case HabitCategory.creativity:
        return '🎨';
      case HabitCategory.social:
        return '👥';
      case HabitCategory.custom:
        return '⚙️';
    }
  }
}
