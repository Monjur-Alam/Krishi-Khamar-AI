import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/location/bloc/location_cubit.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Shows the current location label and lets the user retry / open settings.
class LocationLabel extends StatelessWidget {
  const LocationLabel({
    super.key,
    this.fallback = 'Pune, Maharashtra',
    this.style,
    this.iconColor,
    this.compact = false,
  });

  final String fallback;
  final TextStyle? style;
  final Color? iconColor;
  final bool compact;

  String _statusLabel(BuildContext context, LocationState state) {
    final l10n = context.l10n;
    return switch (state.status) {
      LocationStatus.initial || LocationStatus.requesting =>
        l10n.detectingLocation,
      LocationStatus.denied => l10n.locationDenied,
      LocationStatus.permanentlyDenied => l10n.enableLocationSettings,
      LocationStatus.serviceDisabled => l10n.turnOnLocation,
      LocationStatus.error => state.message ?? l10n.locationUnavailable,
      LocationStatus.ready => state.displayLabel.isNotEmpty
          ? state.displayLabel
          : l10n.yourArea,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final label = state.status == LocationStatus.ready || state.hasFix
            ? (state.displayLabel.isNotEmpty
                ? state.displayLabel
                : (fallback.isNotEmpty ? fallback : context.l10n.yourArea))
            : (state.status == LocationStatus.initial ||
                    state.status == LocationStatus.requesting
                ? context.l10n.detectingLocation
                : _statusLabel(context, state));

        final needsAction = state.status == LocationStatus.denied ||
            state.status == LocationStatus.permanentlyDenied ||
            state.status == LocationStatus.serviceDisabled ||
            state.status == LocationStatus.error;

        return InkWell(
          onTap: needsAction
              ? () {
                  if (state.status == LocationStatus.permanentlyDenied) {
                    context.read<LocationCubit>().openAppSettings();
                  } else {
                    context.read<LocationCubit>().requestAndFetch();
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: compact ? 14 : 16,
                color: iconColor ?? Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style ??
                      TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (state.status == LocationStatus.requesting) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor ?? Colors.white70,
                  ),
                ),
              ] else if (needsAction) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.refresh,
                  size: 14,
                  color: iconColor ?? AppColors.yellow,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}