import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  int _selectedPeriod = 7; // Default to 7 days
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final habits = habitProvider.habits;
        final categories = habitProvider.getAllCategories();
        
        if (habits.isEmpty) {
          return _buildEmptyState();
        }
        
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Period',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment<int>(
                              value: 7,
                              label: Text('7 Days'),
                            ),
                            ButtonSegment<int>(
                              value: 14,
                              label: Text('14 Days'),
                            ),
                            ButtonSegment<int>(
                              value: 30,
                              label: Text('30 Days'),
                            ),
                          ],
                          selected: {_selectedPeriod},
                          onSelectionChanged: (Set<int> selection) {
                            setState(() {
                              _selectedPeriod = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category filter
                if (categories.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String?>(
                            decoration: const InputDecoration(
                              labelText: 'Filter by Category',
                              prefixIcon: Icon(Icons.category),
                            ),
                            value: _selectedCategory,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              )).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Overall completion rate
                _buildOverallCompletionCard(habitProvider),
                const SizedBox(height: 16),
                
                // Completion chart
                _buildCompletionChart(habitProvider),
                const SizedBox(height: 16),
                
                // Streak leaderboard
                _buildStreakLeaderboard(habitProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits to track yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add habits to see your progress',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCompletionCard(HabitProvider habitProvider) {
    // Calculate overall completion rate
    final habits = _selectedCategory != null
        ? habitProvider.habits.where((h) => h.category == _selectedCategory).toList()
        : habitProvider.habits;
    
    if (habits.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No habits in this category'),
        ),
      );
    }
    
    int totalCompletions = 0;
    int totalOpportunities = 0;
    
    for (final habit in habits) {
      final history = habitProvider.getHabitCompletionHistory(habit, _selectedPeriod);
      totalCompletions += history.values.where((completed) => completed).length;
      totalOpportunities += history.length;
    }
    
    final completionRate = totalOpportunities > 0
        ? (totalCompletions * 100 / totalOpportunities).round()
        : 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Completion Rate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: completionRate / 100,
                            strokeWidth: 10,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$completionRate%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last $_selectedPeriod days'),
                      const SizedBox(height: 8),
                      Text('$totalCompletions completed out of $totalOpportunities scheduled'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionChart(HabitProvider habitProvider) {
    // Get data for chart
    final habits = _selectedCategory != null
        ? habitProvider.habits.where((h) => h.category == _selectedCategory).toList()
        : habitProvider.habits;
    
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create a map of date -> completion rate
    final Map<DateTime, int> completionsByDate = {};
    final Map<DateTime, int> totalByDate = {};
    
    // Initialize dates
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      completionsByDate[dateOnly] = 0;
      totalByDate[dateOnly] = 0;
    }
    
    // Count completions
    for (final habit in habits) {
      for (int i = 0; i < _selectedPeriod; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        
        if (habit.isScheduledForDate(date)) {
          totalByDate[dateOnly] = (totalByDate[dateOnly] ?? 0) + 1;
          if (habit.isCompletedForDate(date)) {
            completionsByDate[dateOnly] = (completionsByDate[dateOnly] ?? 0) + 1;
          }
        }
      }
    }
    
    // Convert to chart data
    final List<FlSpot> spots = [];
    final sortedDates = completionsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final completions = completionsByDate[date] ?? 0;
      final total = totalByDate[date] ?? 0;
      final rate = total > 0 ? (completions * 100 / total) : 0;
      spots.add(FlSpot(i.toDouble(), rate.toDouble()));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Rate Over Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat.Md().format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (sortedDates.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakLeaderboard(HabitProvider habitProvider) {
    // Get habits sorted by streak
    final habits = _selectedCategory != null
        ? habitProvider.habits.where((h) => h.category == _selectedCategory).toList()
        : habitProvider.habits;
    
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.streak.compareTo(a.streak));
    
    // Take top 5
    final topHabits = sortedHabits.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streak Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topHabits.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(habit.title),
                subtitle: Text(habit.category),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${habit.streak} day streak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 