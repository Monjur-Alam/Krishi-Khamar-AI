import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../data/models/models.dart';
import '../bloc/scan_bloc.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listenWhen: (p, c) => c.error != null && c.error != p.error,
      listener: (context, state) {
        final error = state.error;
        if (error == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      builder: (context, state) {
        return switch (state.phase) {
          ScanPhase.idle => _ScanIdleView(state: state),
          ScanPhase.analyzing => _AnalyzingView(
              progress: state.progress,
              previewBytes: state.previewBytes,
            ),
          ScanPhase.result => _ResultView(result: state.result!),
        };
      },
    );
  }
}

class _ScanIdleView extends StatelessWidget {
  const _ScanIdleView({required this.state});
  final ScanState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.mintSoft,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.65),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const AppSvgIcon(
                        AppIcons.leaf,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.dropCropPhoto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.supportsJpg,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<ScanBloc>()
                          .add(const ScanBrowsePressed()),
                      icon: const Icon(Icons.upload, size: 18),
                      label: Text(l10n.browsePhoto),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () =>
                  context.read<ScanBloc>().add(const ScanCameraPressed()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.captureWithCamera,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.takePhotoForAi,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.photoTips,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ...state.photoTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.recentScans,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            if (state.recentScans.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  l10n.noScansYet,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ...state.recentScans.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentScanTile(scan: s),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({required this.scan});
  final CropScan scan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isHealthy = scan.risk == ScanRisk.healthy;
    final riskText = switch (scan.risk) {
      ScanRisk.high => l10n.highRisk,
      ScanRisk.healthy => l10n.healthy,
      ScanRisk.medium => l10n.medium,
    };
    final imagePath = scan.imagePath;
    return InkWell(
      onTap: () => context.read<ScanBloc>().add(ScanRecentOpened(scan)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: imagePath != null && File(imagePath).existsSync()
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : ColoredBox(
                        color: AppColors.mint,
                        child: Center(
                          child: Text(
                            scan.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.crop,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${scan.diagnosis} • ${scan.timeAgo}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isHealthy ? AppColors.successSoft : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                riskText,
                style: TextStyle(
                  color: isHealthy ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({
    required this.progress,
    this.previewBytes,
  });
  final double progress;
  final List<int>? previewBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _DetectionHeader(
          onBack: () =>
              context.read<ScanBloc>().add(const ScanAnotherPressed()),
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.mintSoft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  if (previewBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        Uint8List.fromList(previewBytes!),
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Text('🔬', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.analyzingCrop,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aiScanning,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...[
                    l10n.leafTexture,
                    l10n.diseasePattern,
                    l10n.generatingRecs,
                  ].map(
                    (step) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.science_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(step),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});
  final DiseaseResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _DetectionHeader(
          onBack: () =>
              context.read<ScanBloc>().add(const ScanAnotherPressed()),
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.background,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: AppColors.dangerSoft,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${result.name} Detected',
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${result.scientificName} • ${result.severity} Severity',
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${result.matchPercent}% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _InfoBox(
                                    label: l10n.disease, value: result.name),
                                const SizedBox(width: 8),
                                _InfoBox(
                                  label: l10n.severity,
                                  value: result.severity,
                                ),
                                const SizedBox(width: 8),
                                _InfoBox(
                                    label: l10n.spread, value: result.spread),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              result.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.45,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            l10n.treatmentPlan,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...result.treatments.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: t.color,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${t.number}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context
                        .read<ScanBloc>()
                        .add(const ScanAnotherPressed()),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      l10n.scanAnotherCrop,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.mintSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionHeader extends StatelessWidget {
  const _DetectionHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      l10n.cropDiseaseDetection,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.aiPoweredAccuracy,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
