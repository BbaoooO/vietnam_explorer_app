import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared avatar for Discover, Passport and Profile.
class SharedAvatarService {
  static const String defaultAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';

  static final ValueNotifier<String> avatarUrl = ValueNotifier<String>(
    _initialAvatar(),
  );

  static String _initialAvatar() {
    final url = FirebaseAuth.instance.currentUser?.photoURL;
    return url != null && url.isNotEmpty ? url : defaultAvatar;
  }

  static void refreshFromUser() {
    avatarUrl.value = _initialAvatar();
  }

  static Future<void> updateAvatar(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in before changing your profile picture.');
    }
    await user.updatePhotoURL(url);
    avatarUrl.value = url;
  }
}
