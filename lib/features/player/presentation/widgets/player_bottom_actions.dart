import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../equalizer/data/services/equalizer_service.dart';
import '../../../equalizer/presentation/widgets/equalizer_sheet.dart';
import '../bloc/player_cubit.dart';
import 'lyrics_sheet.dart';
import 'queue_sheet.dart';

class PlayerBottomActions extends StatelessWidget {
  const PlayerBottomActions({super.key});

  Future<void> _openSheet(BuildContext context, Widget sheet) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Material3 caps modal bottom sheets to ~640dp on wide screens by
      // default; force it to always span the full device width instead.
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 0.75,
        child: sheet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: () => _openSheet(context, const QueueSheet()),
          icon: Icon(LucideIcons.list_music, color: secondaryColor),
          label: Text('Queue', style: TextStyle(color: secondaryColor)),
        ),
        TextButton.icon(
          onPressed: () {
            final song = context.read<PlayerCubit>().state.currentSong;
            if (song == null) return;
            _openSheet(context, LyricsSheet(song: song));
          },
          icon: Icon(LucideIcons.captions, color: secondaryColor),
          label: Text('Lyrics', style: TextStyle(color: secondaryColor)),
        ),
        if (sl<EqualizerService>().isSupported)
          TextButton.icon(
            onPressed: () => _openSheet(context, const EqualizerSheet()),
            icon: Icon(LucideIcons.sliders_vertical, color: secondaryColor),
            label: Text('EQ', style: TextStyle(color: secondaryColor)),
          ),
      ],
    );
  }
}
