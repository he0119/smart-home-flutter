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

  const SearchState({
    this.status = SearchStatus.initial,
    this.errorMessage = '',
    this.items = const [],
    this.storages = const [],
    this.term = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    String? errorMessage,
    List<Item>? items,
    List<Storage>? storages,
    String? term,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      storages: storages ?? this.storages,
      term: term ?? this.term,
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
      state = const SearchState();
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
      state = state.copyWith(
        status: SearchStatus.success,
        items: results.item1,
        storages: results.item2,
        term: key,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}
