import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/permission_denied_view.dart';
import '../../../music/data/services/music_permission_service.dart';
import '../../domain/entities/folder_entity.dart';
import '../bloc/folders_cubit.dart';

/// Folders tab: every storage folder that holds audio, with its song count.
/// Folders can be hidden from the library (e.g. WhatsApp voice notes).
class FoldersPage extends StatelessWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FoldersCubit>()..load(),
      child: const _FoldersView(),
    );
  }
}

class _FoldersView extends StatelessWidget {
  const _FoldersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Folders', style: theme.textTheme.headlineMedium)),
      body: SafeArea(
        child: BlocBuilder<FoldersCubit, FoldersState>(
          builder: (context, state) {
            final cubit = context.read<FoldersCubit>();
            return switch (state) {
              FoldersLoading() => const Center(child: CircularProgressIndicator()),
              FoldersError(:final message) => Center(child: Text('Something went wrong: $message')),
              FoldersPermissionDenied() => PermissionDeniedView(
                  permanentlyDenied: false,
                  onRequestPermission: () async {
                    await sl<MusicPermissionService>().request();
                    await cubit.refresh();
                  },
                  onOpenSettings: () => sl<MusicPermissionService>().openSettings(),
                ),
              FoldersLoaded(:final folders) when folders.isEmpty => RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(
                          child: Text(
                            'No audio folders found.\nAdd music to your device, then pull to refresh.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              FoldersLoaded(:final folders) => RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    itemCount: folders.length,
                    itemBuilder: (context, index) => _FolderTile(folder: folders[index]),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder});

  final FolderEntity folder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = '${folder.songCount} ${folder.songCount == 1 ? 'song' : 'songs'}';
    final hint = folder.isExcluded
        ? (folder.isSuggestedExclusion ? ' · Hidden (messaging/voice audio)' : ' · Hidden')
        : '';
    return Opacity(
      opacity: folder.isExcluded ? 0.55 : 1,
      child: ListTile(
        onTap: () => context.push(
          '/folder?path=${Uri.encodeQueryComponent(folder.path)}&name=${Uri.encodeQueryComponent(folder.name)}',
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: AppRadius.smRadius,
          ),
          child: Icon(LucideIcons.folder, color: theme.colorScheme.primary),
        ),
        title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '$countLabel$hint\n${folder.displayPath}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: folder.isExcluded ? 'Show in library' : 'Hide from library',
          icon: Icon(folder.isExcluded ? LucideIcons.eye_off : LucideIcons.eye),
          onPressed: () =>
              context.read<FoldersCubit>().setExcluded(folder, excluded: !folder.isExcluded),
        ),
      ),
    );
  }
}
