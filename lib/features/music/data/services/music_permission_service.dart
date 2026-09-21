import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

enum MusicPermissionStatus { granted, denied, permanentlyDenied }

abstract class MusicPermissionService {
  Future<MusicPermissionStatus> check();
  Future<MusicPermissionStatus> request();
  Future<void> openSettings();
}

class MusicPermissionServiceImpl implements MusicPermissionService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<MusicPermissionStatus> check() async {
    final granted = await _audioQuery.permissionsStatus();
    if (granted) return MusicPermissionStatus.granted;

    final status = await Permission.audio.status;
    if (status.isPermanentlyDenied) return MusicPermissionStatus.permanentlyDenied;
    return MusicPermissionStatus.denied;
  }

  @override
  Future<MusicPermissionStatus> request() async {
    final granted = await _audioQuery.permissionsRequest();
    if (granted) return MusicPermissionStatus.granted;

    final status = await Permission.audio.status;
    if (status.isPermanentlyDenied) return MusicPermissionStatus.permanentlyDenied;
    return MusicPermissionStatus.denied;
  }

  @override
  Future<void> openSettings() => openAppSettings();
}
