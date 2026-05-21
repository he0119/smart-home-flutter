import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'search_provider.g.dart';

/// Search state
class SearchState {
  final SearchStatus status;
  final String errorMessage;
  final List<Item> items;
  final List<Storage> storages;
  final String term;
  final List<String> history;

  const SearchState({
    this.status = SearchStatus.initial,
    this.errorMessage = '',
    this.items = const [],
    this.storages = const [],
    this.term = '',
    this.history = const [],
  });

  SearchState copyWith({
    SearchStatus? status,
    String? errorMessage,
    List<Item>? items,
    List<Storage>? storages,
    String? term,
    List<String>? history,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      storages: storages ?? this.storages,
      term: term ?? this.term,
      history: history ?? this.history,
    );
  }

  @override
  String toString() {
    return 'SearchState(status: $status, term: $term, items: ${items.length}, storages: ${storages.length})';
  }
}

enum SearchStatus { initial, loading, success, failure }

/// Search notifier
@riverpod
class Search extends _$Search {
  @override
  SearchState build() {
    return const SearchState();
  }

  Future<void> search(
    String key, {
    bool isDeleted = false,
    bool missingStorage = false,
  }) async {
    if (key.isEmpty) {
      state = SearchState(history: state.history);
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final results = await storageRepository.search(
        key,
        isDeleted: isDeleted,
        missingStorage: missingStorage,
      );
      if (!ref.mounted) return;
      await _saveSearchHistory(key);
      state = state.copyWith(
        status: SearchStatus.success,
        items: results.item1,
        storages: results.item2,
        term: key,
      );
    } on MyException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> loadHistory() async {
    final settingsRepository = ref.read(settingsRepositoryProvider);
    final history = await settingsRepository.searchHistory();
    if (!ref.mounted) return;
    state = state.copyWith(history: history);
  }

  Future<void> removeHistory(String key) async {
    final history = state.history.where((item) => item != key).toList();
    state = state.copyWith(history: history);
    await ref.read(settingsRepositoryProvider).updateSearchHistory(history);
  }

  Future<void> clearHistory() async {
    state = state.copyWith(history: const []);
    await ref.read(settingsRepositoryProvider).clearSearchHistory();
  }

  Future<void> _saveSearchHistory(String key) async {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) return;

    final history = [
      trimmedKey,
      ...state.history.where((item) => item != trimmedKey),
    ].take(SettingsRepository.maxSearchHistoryLength).toList();
    state = state.copyWith(history: history);
    await ref.read(settingsRepositoryProvider).updateSearchHistory(history);
  }
}
