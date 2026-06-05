import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/friend.dart';

class FriendCard extends StatelessWidget {
  final Friend friend;
  const FriendCard({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(friend.grade);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradeColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(color: gradeColor.withOpacity(0.05), blurRadius: 16),
        ],
      ),
      child: Row(children: [
        // Avatar
        _AvatarCircle(emoji: friend.avatarEmoji, color: gradeColor, isOnline: friend.isOnline),
        const SizedBox(width: 14),
        // Name + status
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(friend.name,
                style: GoogleFonts.sora(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: 3),
            Row(children: [
              if (friend.isOnline) ...[
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.green,
                    boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 5),
                Text('Online', style: GoogleFonts.hankenGrotesk(
                    fontSize: 11, color: AppColors.green)),
              ] else
                Text('Offline', style: GoogleFonts.hankenGrotesk(
                    fontSize: 11, color: AppColors.onSurfaceVariant)),
            ]),
          ]),
        ),
        // Score badge
        _ScoreBadge(score: friend.score, grade: friend.grade, color: gradeColor),
      ]),
    );
  }
}

// ── Request card ───────────────────────────────────────────────────────────────

class RequestCard extends StatefulWidget {
  final dynamic request; // FriendRequest
  final Future<void> Function(String id) onAccept;
  final Future<void> Function(String id) onDecline;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(widget.request.grade as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _AvatarCircle(emoji: widget.request.avatarEmoji as String, color: gradeColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.request.name as String,
                  style: GoogleFonts.sora(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.people_outline_rounded,
                    size: 11, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${widget.request.mutualFriends} mutual friends',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 11, color: AppColors.onSurfaceVariant)),
              ]),
            ]),
          ),
          _ScoreBadge(score: widget.request.score as int,
              grade: widget.request.grade as String, color: gradeColor),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _ActionButton(
              label: 'Accept',
              icon: Icons.check_rounded,
              color: AppColors.green,
              loading: _processing,
              onTap: () async {
                setState(() => _processing = true);
                await widget.onAccept(widget.request.id as String);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: 'Decline',
              icon: Icons.close_rounded,
              color: AppColors.onSurfaceVariant,
              outlined: true,
              loading: _processing,
              onTap: () async {
                setState(() => _processing = true);
                await widget.onDecline(widget.request.id as String);
              },
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Suggestion card ────────────────────────────────────────────────────────────

class SuggestionCard extends StatelessWidget {
  final dynamic suggestion; // FriendSuggestion
  final bool invited;
  final VoidCallback onInvite;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.invited,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(suggestion.grade as String);
    final mutualNames = (suggestion.mutualFriendNames as List<String>);
    final mutualLabel = mutualNames.length == 1
        ? mutualNames.first
        : '${mutualNames.first} +${mutualNames.length - 1} more';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mindfulnessGlow.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: AppColors.mindfulnessGlow.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Row(children: [
        _AvatarCircle(emoji: suggestion.avatarEmoji as String, color: gradeColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(suggestion.name as String,
                style: GoogleFonts.sora(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.hub_outlined, size: 11,
                  color: AppColors.mindfulnessGlow.withOpacity(0.8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${mutualNames.length} mutual • $mutualLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 11,
                      color: AppColors.mindfulnessGlow.withOpacity(0.8)),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        _ScoreBadge(
            score: suggestion.score as int,
            grade: suggestion.grade as String,
            color: gradeColor),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: invited ? null : onInvite,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: invited
                  ? AppColors.green.withOpacity(0.12)
                  : AppColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: invited
                    ? AppColors.green.withOpacity(0.4)
                    : AppColors.cyan.withOpacity(0.4),
              ),
              boxShadow: invited
                  ? []
                  : [BoxShadow(color: AppColors.cyan.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Text(
              invited ? 'Sent ✓' : 'Invite',
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: invited ? AppColors.green : AppColors.cyan,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Color _gradeColor(String grade) => switch (grade) {
      'S' => AppColors.cyan,
      'A' => AppColors.green,
      'B' => AppColors.productivityGlow,
      'C' => AppColors.gamingGlow,
      'D' => AppColors.socialGlow,
      _ => AppColors.shortVideoGlow,
    };

class _AvatarCircle extends StatelessWidget {
  final String emoji;
  final Color color;
  final bool isOnline;

  const _AvatarCircle({
    required this.emoji,
    required this.color,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.35)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
        ],
      );
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final String grade;
  final Color color;

  const _ScoreBadge(
      {required this.score, required this.grade, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8)],
            ),
            child: Text(
              '$score',
              style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                  shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 6)]),
            ),
          ),
          const SizedBox(height: 3),
          Text(grade,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.7))),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(outlined ? 0.4 : 0.3)),
            boxShadow: outlined
                ? []
                : [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ]),
        ),
      );
}
