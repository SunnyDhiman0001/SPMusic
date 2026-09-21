import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/spotify/data/services/spotify_auth_service_impl.dart';

void main() {
  group('SpotifyAuthServiceImpl PKCE code challenge', () {
    test('is deterministic for a given verifier', () {
      const verifier = 'fixed-test-verifier-value-1234567890';

      final challengeA = SpotifyAuthServiceImpl.codeChallengeForTest(verifier);
      final challengeB = SpotifyAuthServiceImpl.codeChallengeForTest(verifier);

      expect(challengeA, equals(challengeB));
    });

    test('is base64url-safe (no +, / or = characters)', () {
      const verifier = 'another-fixed-verifier-value-abcdef';

      final challenge = SpotifyAuthServiceImpl.codeChallengeForTest(verifier);

      expect(challenge.contains('+'), isFalse);
      expect(challenge.contains('/'), isFalse);
      expect(challenge.contains('='), isFalse);
    });

    test('differs for different verifiers', () {
      final challengeA = SpotifyAuthServiceImpl.codeChallengeForTest('verifier-one');
      final challengeB = SpotifyAuthServiceImpl.codeChallengeForTest('verifier-two');

      expect(challengeA, isNot(equals(challengeB)));
    });
  });
}
