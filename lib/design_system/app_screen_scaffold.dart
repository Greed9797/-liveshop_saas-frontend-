import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_scaffold.dart';
import 'design_system.dart';

class AppScreenScaffold extends StatelessWidget {
  final String currentRoute;
  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final String? eyebrow;
  final bool titleSerif;

  const AppScreenScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.eyebrow,
    this.titleSerif = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: currentRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            _ScreenHeader(
              title: title!,
              subtitle: subtitle,
              actions: actions,
              eyebrow: eyebrow,
              titleSerif: titleSerif,
            ),
          Expanded(
            child: AppGradientBackground(child: child),
          ),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final String? eyebrow;
  final bool titleSerif;

  const _ScreenHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.eyebrow,
    this.titleSerif = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x6,
        vertical: AppSpacing.x4,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eyebrow != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 1,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  eyebrow!.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: titleSerif
                    ? _buildSerifTitle()
                    : Text(title, style: AppTypography.h2),
              ),
              if (actions != null) ...[
                const SizedBox(width: AppSpacing.x3),
                ...actions!,
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.x1),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSerifTitle() {
    final words = title.split(' ');
    if (words.isEmpty) return const SizedBox.shrink();

    final lastWord = words.last;
    final rest = words.sublist(0, words.length - 1).join(' ');

    return Text.rich(
      TextSpan(
        children: [
          if (rest.isNotEmpty) ...[
            TextSpan(
              text: '$rest ',
              style: AppTypography.h1.copyWith(
                fontSize: 34,
                letterSpacing: -0.03,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          TextSpan(
            text: lastWord,
            style: GoogleFonts.getFont(
              'Instrument Serif',
              fontSize: 38,
              letterSpacing: -0.02,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
