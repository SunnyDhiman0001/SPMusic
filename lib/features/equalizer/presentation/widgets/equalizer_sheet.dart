import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/equalizer_preset.dart';
import '../bloc/equalizer_cubit.dart';
import '../bloc/equalizer_state.dart';

/// Bottom sheet with an on/off switch, preset chips, and one vertical slider
/// per band the device's equalizer exposes.
class EqualizerSheet extends StatelessWidget {
  const EqualizerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<EqualizerCubit, EqualizerState>(
      builder: (context, state) {
        final cubit = context.read<EqualizerCubit>();
        return SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: AppRadius.roundRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(child: Text('Equalizer', style: theme.textTheme.headlineMedium)),
                    if (state.status == EqualizerStatus.ready) ...[
                      TextButton(onPressed: cubit.reset, child: const Text('Reset')),
                      Switch(value: state.enabled, onChanged: cubit.setEnabled),
                    ],
                  ],
                ),
              ),
              Expanded(child: _body(context, state, cubit)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, EqualizerState state, EqualizerCubit cubit) {
    final theme = Theme.of(context);
    switch (state.status) {
      case EqualizerStatus.unsupported:
        return const _Message('The equalizer is not available on this device.');
      case EqualizerStatus.waitingForAudio:
        return const _Message('Play a song to start using the equalizer.');
      case EqualizerStatus.ready:
        break;
    }
    return Opacity(
      opacity: state.enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !state.enabled,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: EqualizerPreset.all.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final preset = EqualizerPreset.all[i];
                  return ChoiceChip(
                    label: Text(preset.name),
                    selected: state.presetId == preset.id,
                    onSelected: (_) => cubit.selectPreset(preset),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    for (final band in state.bands)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${band.gainDb >= 0 ? '+' : ''}${band.gainDb.toStringAsFixed(1)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Expanded(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  min: state.minDb,
                                  max: state.maxDb,
                                  value: band.gainDb.clamp(state.minDb, state.maxDb),
                                  onChanged: (v) => cubit.setBandGain(band.index, v),
                                  onChangeEnd: (_) => cubit.persist(),
                                ),
                              ),
                            ),
                            Text(band.label, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
}
