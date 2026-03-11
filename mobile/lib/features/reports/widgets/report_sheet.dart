import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/reports/providers/report_providers.dart';
import 'package:mobile/features/reports/providers/report_reasons_provider.dart';

enum ReportTargetType { property, user }

class ReportSheet extends ConsumerStatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final String targetTitle;

  const ReportSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required ReportTargetType targetType,
    required String targetId,
    required String targetTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReportSheet(
        targetType: targetType,
        targetId: targetId,
        targetTitle: targetTitle,
      ),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _selectedReason;
  final _customReasonCtrl = TextEditingController();
  bool _showCustomField = false;
  bool _loading = false;

  @override
  void dispose() {
    _customReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _selectedReason == 'Other'
        ? _customReasonCtrl.text.trim()
        : _selectedReason;

    if (reason == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select or enter a reason',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final authService = AuthService();
      final currentUserId = await authService.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('You must be logged in to submit a report');
      }

      await ref
          .read(reportNotifierProvider.notifier)
          .submit(
            reporterId: currentUserId,
            reportedPropertyId: widget.targetType == ReportTargetType.property
                ? widget.targetId
                : null,
            reportedUserId: widget.targetType == ReportTargetType.user
                ? widget.targetId
                : null,
            reason: reason,
          );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report submitted. Our team will review it.',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );

      ref.read(reportNotifierProvider.notifier).reset();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.outfit()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isProperty = widget.targetType == ReportTargetType.property;
    final reasonsAsync = ref.watch(reportReasonsProvider);

    return reasonsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            'Failed to load reasons',
            style: GoogleFonts.outfit(color: AppColors.error),
          ),
        ),
      ),
      data: (reasons) {
        final resolvedReasons = reasons.isEmpty
            ? ['Other']
            : reasons.contains('Other')
                ? reasons
                : [...reasons, 'Other'];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.flag_outlined,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isProperty ? 'Report Property' : 'Report User',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            widget.targetTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'What\'s the issue?',
                  style: tt.labelLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ...resolvedReasons.map((reason) {
                  final selected = _selectedReason == reason;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReason = reason;
                        _showCustomField = reason == 'Other';
                        if (reason != 'Other') _customReasonCtrl.clear();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.subtleBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.error
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.error
                                    : AppColors.accent,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                if (_showCustomField) ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller: _customReasonCtrl,
                    maxLines: 3,
                    maxLength: 300,
                    autofocus: true,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      hintStyle: GoogleFonts.outfit(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppColors.subtleBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.subtleBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reports are reviewed by our team. False reports may result in account suspension.',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      disabledBackgroundColor: AppColors.error.withValues(
                        alpha: 0.5,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Submit Report',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}