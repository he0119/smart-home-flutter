import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/repository_providers.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Authentication state (Riverpod version)
class AuthState {
  final AsyncValue<User?> user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AsyncValue<User?>? user,
    String? Function()? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Authentication Notifier
class AuthenticationNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 启动时自动检查登录状态
    _checkAuthentication();
    return AuthState(user: const AsyncValue.loading());
  }

  Future<void> _checkAuthentication() async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);

    try {
      if (settings.isLogin) {
        // 每次启动时都获取当前用户信息，并更新本地缓存
        final userRepository = ref.read(userRepositoryProvider);
        final user = await userRepository.currentUser();
        await settingsNotifier.updateLoginUser(user);
        state = AuthState(user: AsyncValue.data(user));
      } else {
        state = AuthState(user: const AsyncValue.data(null));
      }
    } on MyException catch (e) {
      state = AuthState(
        user: AsyncValue.error(e, StackTrace.current),
        errorMessage: e.message,
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final graphqlApiClient = ref.read(graphQLApiClientProvider);
      final user = await graphqlApiClient.login(username, password);

      if (user != null) {
        final settingsNotifier = ref.read(settingsProvider.notifier);
        await settingsNotifier.updateLoginUser(user);
        state = AuthState(user: AsyncValue.data(user));
      } else {
        state = AuthState(
          user: const AsyncValue.data(null),
          errorMessage: '用户名或密码错误',
          isLoading: false,
        );
      }
    } on MyException catch (e) {
      state = AuthState(
        user: const AsyncValue.data(null),
        errorMessage: e.message,
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    final graphqlApiClient = ref.read(graphQLApiClientProvider);
    final result = await graphqlApiClient.logout();

    if (result) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.updateLoginUser(null);
      state = AuthState(user: const AsyncValue.data(null), errorMessage: '已登出');
    }
  }

  Future<void> oidcLogin() async {
    state = state.copyWith(isLoading: true);

    try {
      final graphqlApiClient = ref.read(graphQLApiClientProvider);
      final user = await graphqlApiClient.oidcLogin();

      if (user != null) {
        final settingsNotifier = ref.read(settingsProvider.notifier);
        await settingsNotifier.updateLoginUser(user);
        state = AuthState(user: AsyncValue.data(user));
      } else {
        state = AuthState(
          user: const AsyncValue.data(null),
          errorMessage: 'OIDC 登录失败',
          isLoading: false,
        );
      }
    } on MyException catch (e) {
      state = AuthState(
        user: const AsyncValue.data(null),
        errorMessage: e.message,
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null);
  }
}

/// Authentication provider
final authenticationProvider =
    NotifierProvider<AuthenticationNotifier, AuthState>(
      AuthenticationNotifier.new,
    );

/// Convenience provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authenticationProvider);
  return authState.user.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Convenience provider for login status
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
