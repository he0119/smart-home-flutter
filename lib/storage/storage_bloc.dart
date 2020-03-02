import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/serializers.dart';
import 'package:smart_home/services/graphql_service.dart';

part 'storage_events.dart';
part 'storage_states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => StorageInitial();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StorageSearch) {
      final QueryOptions options = QueryOptions(
        documentNode: gql(search), // this is the query string you just created
        variables: {
          'key': event.key,
        },
      );
      final results = await graphqlService.query(options);
      if (results.hasException) {
        yield StorageSearchError(results.exception);
        return;
      }
      final List<dynamic> storages = results.data['search']['storages'];
      final List<dynamic> items = results.data['search']['items'];
      final List<Storage> listofStorage = storages
          .map(
              (dynamic e) => serializers.deserializeWith(Storage.serializer, e))
          .toList();
      final List<Item> listofItem = items
          .map((dynamic e) => serializers.deserializeWith(Item.serializer, e))
          .toList();
      yield StorageSearchResults(listofItem, listofStorage);
    }
  }
}
