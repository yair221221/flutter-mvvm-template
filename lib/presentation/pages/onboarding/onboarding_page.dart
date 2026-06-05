import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../viewmodels/user_viewmodel.dart';

const _kAvatars = [
  '🐱','🦊','🐸','🦁','🐙','🦋','🐻','🦅',
  '🦚','🦩','🐠','🌵','🦜','🐧','🦋','🐝',
  '🦎','🐬','🐳','🦄',
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();
  String _selectedEmoji = _kAvatars[0];
  bool _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      return;
    }
    setState(() { _saving = true; _nameError = null; });

    await context.read<UserViewModel>().completeOnboarding(
          displayName: name,
          avatarEmoji: _selectedEmoji,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Glow orbs
        Positioned(
            top: -60, right: -60,
            child: _Orb(color: AppColors.cyan, size: 300)),
        Positioned(
            bottom: 100, left: -80,
            child: _Orb(color: AppColors.green, size: 260)),
        // Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.12),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.cyan.withOpacity(0.3),
                        blurRadius: 20),
                  ],
                ),
                child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 24),
              Text('Welcome to\nDigital Wellness',
                  style: GoogleFonts.sora(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      height: 1.2,
                      shadows: [
                        Shadow(
                            color: AppColors.cyan.withOpacity(0.3),
                            blurRadius: 12),
                      ])),
              const SizedBox(height: 10),
              Text(
                  'Set up your profile to share scores\nwith friends in real time.',
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6)),
              const SizedBox(height: 40),
              // Name field
              Text('YOUR NAME',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: GoogleFonts.sora(
                    fontSize: 16, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g. Alex',
                  hintStyle: GoogleFonts.sora(
                      color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                  errorText: _nameError,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                  ),
                ),
                onChanged: (_) =>
                    setState(() => _nameError = null),
              ),
              const SizedBox(height: 32),
              // Avatar picker
              Text('PICK AN AVATAR',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _kAvatars.map((emoji) {
                  final selected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.cyan.withOpacity(0.2)
                            : AppColors.surfaceContainerLow,
                        border: Border.all(
                          color: selected
                              ? AppColors.cyan
                              : AppColors.outlineVariant.withOpacity(0.3),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: AppColors.cyan.withOpacity(0.4),
                                    blurRadius: 12)
                              ]
                            : [],
                      ),
                      child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 24))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              // CTA button
              Consumer<UserViewModel>(builder: (_, vm, __) {
                final loading = _saving ||
                    vm.state == UserSetupState.checking;
                return GestureDetector(
                  onTap: loading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.cyan.withOpacity(0.5),
                            blurRadius: 24),
                        BoxShadow(
                            color: AppColors.cyan.withOpacity(0.2),
                            blurRadius: 48,
                            spreadRadius: 4),
                      ],
                    ),
                    child: Center(
                      child: loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: AppColors.background, strokeWidth: 2))
                          : Text("LET'S GO →",
                              style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.background,
                                  letterSpacing: 1.5)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Your data is private by default.\nOnly friends see your score.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.05),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: size * 0.7,
                spreadRadius: size * 0.1),
          ],
        ),
      );
}
