import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/score_ring.dart';
import 'widgets/usage_breakdown.dart';
import 'widgets/app_usage_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(children: [
        Positioned(top: -80, right: -60,  child: _GlowOrb(color: AppColors.cyan, size: 300)),
        Positioned(bottom: 200, left: -80, child: _GlowOrb(color: AppColors.green, size: 260)),
        Positioned(top: 400, right: -40,  child: _GlowOrb(color: AppColors.mindfulnessGlow, size: 200)),
        Consumer<DashboardViewModel>(builder: (context, vm, _) {
          switch (vm.state) {
            case DashboardState.initial:
            case DashboardState.loading:       return _LoadingScreen();
            case DashboardState.permissionRequired: return _PermissionScreen(onGrant: vm.grantPermission);
            case DashboardState.error:         return _ErrorScreen(message: vm.errorMessage, onRetry: vm.load);
            case DashboardState.success:       return _SuccessBody(vm: vm);
          }
        }),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent, elevation: 0,
    title: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cyan.withOpacity(0.15),
          border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 12)],
        ),
        child: const Icon(Icons.monitor_heart_outlined, color: AppColors.cyan, size: 18),
      ),
      const SizedBox(width: 10),
      Text('Digital Wellness', style: GoogleFonts.sora(
          fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
    ]),
    actions: [
      IconButton(
        icon: const Icon(Icons.info_outline_rounded, color: AppColors.onSurfaceVariant),
        onPressed: () => showModalBottomSheet(
          context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
          builder: (_) => const _ScoringInfoSheet(),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );
}

// ── Success body ──────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final DashboardViewModel vm;
  const _SuccessBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    final score = vm.score!;
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.surfaceContainerLow,
      onRefresh: vm.load,
      child: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
        SliverToBoxAdapter(child: _DateNav(date: vm.selectedDate,
            onPrev: vm.goToPreviousDay, onNext: vm.goToNextDay)),
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(child: _HeroCard(score: score))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(child: Row(children: [
              Expanded(child: _StatCard(icon: Icons.trending_down_rounded, label: 'PENALTY',
                  value: score.totalPenalty.toStringAsFixed(0), color: AppColors.shortVideoGlow)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.trending_up_rounded, label: 'BONUS',
                  value: '+${score.totalBonus.toStringAsFixed(0)}', color: AppColors.green)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.directions_walk_rounded, label: 'STEPS',
                  value: score.steps.toString(), color: AppColors.cyan)),
            ]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(child: UsageBreakdownWidget(score: score))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(child: AppUsageListWidget(score: score))),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ]),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final score;
  const _HeroCard({required this.score});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D2137).withOpacity(0.85),
                  const Color(0xFF1A0D2E).withOpacity(0.85),
                  const Color(0xFF002A2E).withOpacity(0.85),
                ]),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.cyan.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.1), blurRadius: 40)],
          ),
          child: Center(child: ScoreRingWidget(score: score)),
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 16)],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: color,
            shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)])),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }
}

// ── Date nav ──────────────────────────────────────────────────────────────────

class _DateNav extends StatelessWidget {
  final DateTime date; final VoidCallback onPrev, onNext;
  const _DateNav({required this.date, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _NavBtn(icon: Icons.chevron_left_rounded, onPressed: onPrev),
      const SizedBox(width: 8),
      Text(isToday ? 'Today' : '${date.day}/${date.month}/${date.year}',
          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant)),
      const SizedBox(width: 8),
      _NavBtn(icon: Icons.chevron_right_rounded, onPressed: isToday ? null : onNext),
    ]);
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon; final VoidCallback? onPressed;
  const _NavBtn({required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4))),
      child: Icon(icon, size: 18,
          color: onPressed != null ? AppColors.onSurface : AppColors.onSurfaceVariant.withOpacity(0.3)),
    ),
  );
}

// ── Glow orb ──────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color; final double size;
  const _GlowOrb({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
        color: color.withOpacity(0.06),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.18), blurRadius: size * 0.7, spreadRadius: size * 0.1),
          BoxShadow(color: color.withOpacity(0.08), blurRadius: size, spreadRadius: size * 0.3),
        ]),
  );
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
    const SizedBox(height: 16),
    Text('Loading wellness data...', style: GoogleFonts.hankenGrotesk(
        color: AppColors.onSurfaceVariant, fontSize: 14)),
  ]));
}

// ── Permission ────────────────────────────────────────────────────────────────

class _PermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionScreen({required this.onGrant});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.cyan.withOpacity(0.1),
              border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 24)]),
          child: const Center(child: Text('📊', style: TextStyle(fontSize: 36)))),
      const SizedBox(height: 24),
      Text('Usage Access Required', style: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
      const SizedBox(height: 12),
      Text('Grant Usage Access to see your real screen time and wellness score.',
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.6)),
      const SizedBox(height: 32),
      _NeonButton(label: 'GRANT ACCESS', icon: Icons.settings_outlined, onTap: onGrant),
    ]),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorScreen({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.shortVideoGlow),
    const SizedBox(height: 12),
    Text(message, textAlign: TextAlign.center,
        style: GoogleFonts.hankenGrotesk(color: AppColors.onSurfaceVariant)),
    const SizedBox(height: 20),
    _NeonButton(label: 'RETRY', icon: Icons.refresh_rounded, onTap: onRetry),
  ]));
}

// ── Neon button ───────────────────────────────────────────────────────────────

class _NeonButton extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _NeonButton({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cyanGradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: AppColors.cyan.withOpacity(0.5), blurRadius: 24),
          BoxShadow(color: AppColors.cyan.withOpacity(0.2), blurRadius: 48, spreadRadius: 4),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.background, size: 18),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700,
            color: AppColors.background, letterSpacing: 1.5)),
      ]),
    ),
  );
}

// ── Scoring info sheet ────────────────────────────────────────────────────────

class _ScoringInfoSheet extends StatelessWidget {
  const _ScoringInfoSheet();
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Scoring Formula', style: GoogleFonts.sora(
              fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 14),
          _ScoreRow('🎵 Short-video',    '-3 pts / 10 min',    AppColors.shortVideoGlow),
          _ScoreRow('📱 Social media',   '-2 pts / 10 min',    AppColors.socialGlow),
          _ScoreRow('🎮 Gaming',         '-1.5 pts / 10 min',  AppColors.gamingGlow),
          _ScoreRow('💬 Other apps',     '-1 pt / 10 min',     AppColors.neutralGlow),
          Divider(color: AppColors.outlineVariant.withOpacity(0.4), height: 20),
          _ScoreRow('🎓 Educational',    '+2 pts / 10 min',    AppColors.educationGlow),
          _ScoreRow('📚 Reading',        '+2 pts / 10 min',    AppColors.readingGlow),
          _ScoreRow('🧘 Mindfulness',    '+1.5 pts / 10 min',  AppColors.mindfulnessGlow),
          _ScoreRow('⚙️ Productivity',   '+1 pt / 10 min',     AppColors.productivityGlow),
          Divider(color: AppColors.outlineVariant.withOpacity(0.4), height: 20),
          _ScoreRow('🚶 Steps',          '+1 per 2,000 (max +10)', AppColors.cyan),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cyan.withOpacity(0.2))),
            child: Text('Score = 100 − penalties + bonuses  •  Clamped 0–100',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 11, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
          ),
        ]),
      ),
    ),
  );
}

class _ScoreRow extends StatelessWidget {
  final String label, value; final Color color;
  const _ScoreRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.onSurface)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100)),
        child: Text(value, style: GoogleFonts.jetBrainsMono(
            fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    ]),
  );
}
