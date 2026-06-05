import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/score_ring.dart';
import 'widgets/usage_breakdown.dart';
import 'widgets/app_usage_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load today's data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Digital Wellness'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showScoringInfo(context),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          switch (vm.state) {
            case DashboardState.initial:
            case DashboardState.loading:
              return const Center(child: CircularProgressIndicator());

            case DashboardState.permissionRequired:
              return _PermissionScreen(onGrant: vm.grantPermission);

            case DashboardState.error:
              return _ErrorScreen(
                  message: vm.errorMessage, onRetry: vm.load);

            case DashboardState.success:
              return _SuccessBody(vm: vm);
          }
        },
      ),
    );
  }

  void _showScoringInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ScoringInfoSheet(),
    );
  }
}

// ── Success content ──────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final DashboardViewModel vm;
  const _SuccessBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    final score = vm.score!;
    return RefreshIndicator(
      onRefresh: vm.load,
      child: CustomScrollView(
        slivers: [
          // Date navigation
          SliverToBoxAdapter(
            child: _DateNav(
              date: vm.selectedDate,
              onPrev: vm.goToPreviousDay,
              onNext: vm.goToNextDay,
            ),
          ),
          // Score ring + grade
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: ScoreRingWidget(score: score)),
            ),
          ),
          // Score summary chips
          SliverToBoxAdapter(child: _SummaryRow(score: score)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Breakdown chart
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: UsageBreakdownWidget(score: score),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // App list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppUsageListWidget(score: score),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DateNav extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _DateNav({required this.date, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final label = isToday
        ? 'Today'
        : '${date.day}/${date.month}/${date.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        IconButton(
          icon: Icon(Icons.chevron_right,
              color: isToday ? Colors.grey[400] : null),
          onPressed: isToday ? null : onNext,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final score;
  const _SummaryRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SummaryChip(
            icon: Icons.trending_down,
            label: '${score.totalPenalty.toStringAsFixed(0)} penalty',
            color: Colors.red,
          ),
          _SummaryChip(
            icon: Icons.trending_up,
            label: '+${score.totalBonus.toStringAsFixed(0)} bonus',
            color: Colors.green,
          ),
          _SummaryChip(
            icon: Icons.directions_walk,
            label: '${score.steps} steps',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Permission screen ─────────────────────────────────────────────────────────

class _PermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionScreen({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Usage Access Required',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'To show your Digital Wellness Score, grant Usage Access permission in Settings.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onGrant,
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

// ── Error screen ──────────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Scoring info sheet ────────────────────────────────────────────────────────

class _ScoringInfoSheet extends StatelessWidget {
  const _ScoringInfoSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('How is my score calculated?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const _InfoRow('📱 Short-video apps', '-3 pts per 10 min', Colors.red),
          const _InfoRow('👥 Social media', '-2 pts per 10 min', Color(0xFFFF7043)),
          const _InfoRow('🎮 Games', '-1.5 pts per 10 min', Colors.orange),
          const _InfoRow('🌐 Other apps', '-1 pt per 10 min', Colors.grey),
          const Divider(height: 16),
          const _InfoRow('📚 Educational apps', '+2 pts per 10 min', Colors.green),
          const _InfoRow('📖 Reading apps', '+2 pts per 10 min', Colors.blue),
          const _InfoRow('🧘 Mindfulness apps', '+1.5 pts per 10 min', Colors.purple),
          const _InfoRow('✅ Productivity apps', '+1 pt per 10 min', Colors.teal),
          const Divider(height: 16),
          const _InfoRow('🚶 Steps', '+1 per 2,000 steps (max +10)', Colors.blue),
          const SizedBox(height: 8),
          Text(
            'Score = 100 − penalties + bonuses  •  Clamped 0–100',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}
