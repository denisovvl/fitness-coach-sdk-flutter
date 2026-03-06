/// Represents the current authentication state of the Zing SDK.
sealed class SdkAuthState {
  const SdkAuthState();

  factory SdkAuthState.fromMap(Map<String, dynamic> map) {
    return switch (map['state'] as String) {
      'loggedOut' => const SdkAuthStateLoggedOut(),
      'inProgress' => const SdkAuthStateInProgress(),
      'authenticated' => const SdkAuthStateAuthenticated(),
      _ => throw ArgumentError('Unknown auth state: ${map['state']}'),
    };
  }
}

/// The user is not authenticated.
class SdkAuthStateLoggedOut extends SdkAuthState {
  const SdkAuthStateLoggedOut();

  @override
  bool operator ==(Object other) => other is SdkAuthStateLoggedOut;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SdkAuthState.loggedOut';
}

/// Authentication is in progress.
class SdkAuthStateInProgress extends SdkAuthState {
  const SdkAuthStateInProgress();

  @override
  bool operator ==(Object other) => other is SdkAuthStateInProgress;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SdkAuthState.inProgress';
}

/// The user is authenticated.
class SdkAuthStateAuthenticated extends SdkAuthState {
  const SdkAuthStateAuthenticated();

  @override
  bool operator ==(Object other) => other is SdkAuthStateAuthenticated;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SdkAuthState.authenticated';
}
