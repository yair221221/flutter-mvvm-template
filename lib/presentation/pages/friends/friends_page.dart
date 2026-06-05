import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/friends_viewmodel.dart';
import 'widgets/friend_cards.dart';
import 'widgets/invite_sheet.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsViewModel>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => InviteSheet(
        generateInviteText:
            () => context.read<FriendsViewModel>().generateInviteText(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      floatingActionButton: _buildFAB(),
      body: Stack(children: [
        // Background glow orbs
        Positioned(
            top: -60, left: -60,
            child: _GlowOrb(color: AppColors.mindfulnessGlow, size: 280)),
        Positioned(
            bottom: 160, right: -80,
            child: _GlowOrb(color: AppColors.green, size: 240)),
        // Content
        Consumer<FriendsViewModel>(
          builder: (context, vm, _) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
              _buildSliverAppBar(vm),
            ],
            body: switch (vm.state) {
              FriendsLoadState.initial ||
              FriendsLoadState.loading =>
                const _LoadingView(),
              FriendsLoadState.error =>
                _ErrorView(message: vm.errorMessage ?? 'Error', onRetry: vm.load),
              FriendsLoadState.success => TabBarView(
                  controller: _tabController,
                  children: [
                    _FriendsTab(vm: vm),
                    _RequestsTab(vm: vm),
                    _DiscoverTab(vm: vm),
                  ],
                ),
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildFAB() => FloatingActionButton.extended(
        onPressed: _showInviteSheet,
        backgroundColor: AppColors.cyan,
        icon: const Icon(Icons.person_add_alt_1_rounded,
            color: AppColors.background, size: 20),
        label: Text('Invite',
            style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.background)),
        elevation: 0,
      );

  Widget _buildSliverAppBar(FriendsViewModel vm) => SliverAppBar(
        pinned: true,
        floating: false,
        expandedHeight: 140,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 56),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Friends',
                      style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          shadows: [
                            Shadow(
                                color: AppColors.cyan.withOpacity(0.3),
                                blurRadius: 12)
                          ])),
                  Text(
                    '${vm.friends.length} friends · ${vm.requestCount} pending',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ]),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _NeonTabBar(controller: _tabController, requestCount: vm.requestCount),
        ),
      );
}

// ── Neon tab bar ───────────────────────────────────────────────────────────────

class _NeonTabBar extends StatelessWidget {
  final TabController controller;
  final int requestCount;

  const _NeonTabBar({required this.controller, required this.requestCount});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.background.withOpacity(0.9),
        child: TabBar(
          controller: controller,
          indicatorColor: AppColors.cyan,
          indicatorWeight: 2,
          labelColor: AppColors.cyan,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: [
            const Tab(text: 'MY FRIENDS'),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('REQUESTS'),
                if (requestCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text('$requestCount',
                        style: GoogleFonts.sora(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.background)),
                  ),
                ],
              ]),
            ),
            const Tab(text: 'DISCOVER'),
          ],
        ),
      );
}

// ── Friends tab ────────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  final FriendsViewModel vm;
  const _FriendsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.friends.isEmpty) {
      return _EmptyState(
        emoji: '👥',
        title: 'No friends yet',
        subtitle: 'Accept requests or invite friends to get started.',
        color: AppColors.cyan,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.friends.length,
      itemBuilder: (_, i) => FriendCard(friend: vm.friends[i]),
    );
  }
}

// ── Requests tab ───────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  final FriendsViewModel vm;
  const _RequestsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.requests.isEmpty) {
      return _EmptyState(
        emoji: '📬',
        title: 'No pending requests',
        subtitle: 'When someone sends you a request, it will appear here.',
        color: AppColors.green,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.requests.length,
      itemBuilder: (_, i) => RequestCard(
        request: vm.requests[i],
        onAccept: vm.accept,
        onDecline: vm.decline,
      ),
    );
  }
}

// ── Discover tab ───────────────────────────────────────────────────────────────

class _DiscoverTab extends StatelessWidget {
  final FriendsViewModel vm;
  const _DiscoverTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.suggestions.isEmpty) {
      return _EmptyState(
        emoji: '🌐',
        title: 'No suggestions yet',
        subtitle: 'Add more friends to unlock people you might know.',
        color: AppColors.mindfulnessGlow,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.suggestions.length,
      itemBuilder: (_, i) {
        final s = vm.suggestions[i];
        return SuggestionCard(
          suggestion: s,
          invited: vm.invitedIds.contains(s.id),
          onInvite: () {
            vm.markInvited(s.id);
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => InviteSheet(
                generateInviteText: () => vm.generateInviteText(),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
      );
}

// ── Error ──────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.shortVideoGlow),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.hankenGrotesk(
                  color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: GoogleFonts.sora(color: AppColors.cyan,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.35)),
                boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 20)],
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5)),
          ]),
        ),
      );
}

// ── Glow orb ───────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.05),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: size * 0.7,
                spreadRadius: size * 0.1),
            BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: size,
                spreadRadius: size * 0.3),
          ],
        ),
      );
}
