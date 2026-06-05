import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class InviteSheet extends StatefulWidget {
  final Future<String> Function() generateInviteText;
  const InviteSheet({super.key, required this.generateInviteText});

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  String? _inviteText;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final text = await widget.generateInviteText();
    if (mounted) setState(() => _inviteText = text);
  }

  Future<void> _openWhatsApp() async {
    if (_inviteText == null) return;
    final encoded = Uri.encodeComponent(_inviteText!);
    final uri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('WhatsApp not found. Try copying the link!');
    }
  }

  Future<void> _openSms() async {
    if (_inviteText == null) return;
    final encoded = Uri.encodeComponent(_inviteText!);
    final uri = Uri.parse('sms:?body=$encoded');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Could not open Messages. Try copying the link!');
    }
  }

  Future<void> _copyLink() async {
    if (_inviteText == null) return;
    await Clipboard.setData(ClipboardData(text: _inviteText!));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.hankenGrotesk(color: AppColors.onSurface)),
      backgroundColor: AppColors.surfaceContainerHigh,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 40),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.12),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.35)),
                  boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 12)],
                ),
                child: const Icon(Icons.person_add_alt_1_rounded,
                    color: AppColors.cyan, size: 18),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Invite Friends',
                    style: GoogleFonts.sora(
                        fontSize: 17, fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                Text('Share your invite link',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, color: AppColors.onSurfaceVariant)),
              ]),
            ]),
            const SizedBox(height: 24),
            // Invite text preview
            if (_inviteText != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                child: Text(
                  _inviteText!,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              )
            else
              const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.cyan, strokeWidth: 2),
                ),
              ),
            const SizedBox(height: 24),
            // Action buttons
            Row(children: [
              Expanded(child: _ShareButton(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: _openWhatsApp,
              )),
              const SizedBox(width: 10),
              Expanded(child: _ShareButton(
                icon: Icons.message_rounded,
                label: 'Messages',
                color: AppColors.productivityGlow,
                onTap: _openSms,
              )),
              const SizedBox(width: 10),
              Expanded(child: _ShareButton(
                icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                label: _copied ? 'Copied!' : 'Copy Link',
                color: _copied ? AppColors.green : AppColors.mindfulnessGlow,
                onTap: _copyLink,
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12)],
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22,
                shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 8)]),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.sora(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );
}
