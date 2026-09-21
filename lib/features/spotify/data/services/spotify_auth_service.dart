/// Abstraction over the Spotify OAuth2 (PKCE) session lifecycle.
///
/// Kept as an interface (mirroring `AudioPlayerService`/`JustAudioPlayerService`)
/// so that higher layers (datasource, repository, tests) can depend on this
/// contract without pulling in `flutter_web_auth_2` / `flutter_secure_storage`.
abstract class SpotifyAuthService {
  /// True if there is a usable (non-expired, or successfully refreshed)
  /// access token available.
  Future<bool> hasValidSession();

  /// Runs the full PKCE authorization-code flow via the system browser and
  /// stores the resulting tokens securely.
  Future<void> login();

  /// Returns a currently-valid access token, transparently refreshing it if
  /// it has expired. Throws if there is no session or the refresh fails.
  Future<String> getValidAccessToken();

  /// Clears any stored session.
  Future<void> logout();
}
