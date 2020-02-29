import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/services/graphql_service.dart';
import 'package:smart_home/storage/models/serializers.dart';

import '../graphql/queries/queries.dart';
import '../models/models.dart';

part 'events.dart';
part 'states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => Initial();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StartSearch) {
      final QueryOptions options = QueryOptions(
        documentNode: gql(search), // this is the query string you just created
        variables: {
          'key': event.key,
        },
      );
      final results = await graphqlService.query(options);
      if (results.hasException) {
        yield SearchError(results.exception);
        return;
      }
      final List<dynamic> storages = results.data['search']['storages'];
      final List<dynamic> items = results.data['search']['items'];
      final List<Storage> listofStorage = storages
          .map((dynamic e) =>
              serializers.deserializeWith(Storage.serializer, e))
          .toList();
      final List<Item> listofItem = items
          .map((dynamic e) => serializers.deserializeWith(Item.serializer, e))
          .toList();
      yield SearchResults(listofItem, listofStorage);
    }
  }
}
