import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/task_model.dart';
import '../services/auth_provider.dart';
import '../services/quote_provider.dart';
import '../services/task_provider.dart';
import '../utils/snackbar_util.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    final String? error = context.read<AuthProvider>().errorMessage;
    if (error != null) {
      SnackBarUtil.showError(context, error);
    } else {
      SnackBarUtil.showMessage(context, 'Logged out successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final QuoteProvider quoteProvider = context.watch<QuoteProvider>();
    final String userId = authProvider.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: authProvider.isLoading ? null : () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: taskProvider.isLoading && taskProvider.tasks.isEmpty,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait(<Future<void>>[
              taskProvider.refreshTasks(userId),
              quoteProvider.fetchQuote(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              QuoteCard(
                quote: quoteProvider.quote,
                isLoading: quoteProvider.isLoading,
                onRefresh: quoteProvider.fetchQuote,
              ),
              const SizedBox(height: 16),
              _TaskFilterSection(
                currentFilter: taskProvider.currentFilter,
                onChanged: taskProvider.setFilter,
              ),
              const SizedBox(height: 16),
              if (taskProvider.filteredTasks.isEmpty)
                const EmptyState(
                  icon: Icons.inbox_rounded,
                  title: 'No tasks found',
                  subtitle:
                      'Add a new task or change the filter to view tasks here.',
                )
              else
                ...taskProvider.filteredTasks.map(
                  (TaskModel task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(
                      task: task,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddEditTaskScreen(task: task),
                          ),
                        );
                      },
                      onToggleComplete: (bool value) {
                        taskProvider.toggleTaskCompletion(
                          userId: userId,
                          task: task,
                          value: value,
                        );
                      },
                      onDelete: () async {
                        final bool confirmed =
                            await showDeleteConfirmationDialog(context);
                        if (!confirmed) return;
                        await taskProvider.deleteTask(
                          userId: userId,
                          taskId: task.id,
                        );
                        if (!context.mounted) return;
                        SnackBarUtil.showMessage(context, 'Task deleted');
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _TaskFilterSection extends StatelessWidget {
  const _TaskFilterSection({
    required this.currentFilter,
    required this.onChanged,
  });

  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text(AppConstants.allFilter),
          selected: currentFilter == TaskFilter.all,
          onSelected: (_) => onChanged(TaskFilter.all),
        ),
        FilterChip(
          label: const Text(AppConstants.completedFilter),
          selected: currentFilter == TaskFilter.completed,
          onSelected: (_) => onChanged(TaskFilter.completed),
        ),
        FilterChip(
          label: const Text(AppConstants.pendingFilter),
          selected: currentFilter == TaskFilter.pending,
          onSelected: (_) => onChanged(TaskFilter.pending),
        ),
      ],
    );
  }
}
