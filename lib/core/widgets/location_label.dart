import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/location/bloc/location_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final label = state.status == LocationStatus.ready || state.hasFix
            ? state.displayLabel
            : (state.status == LocationStatus.initial ||
                    state.status == LocationStatus.requesting
                ? state.displayLabel
                : fallback);

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
