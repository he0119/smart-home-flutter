import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/services/client.dart';

import '../graphql/queries/queries.dart';
import '../models/models.dart';

part 'events.dart';
part 'states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final GraphQLClient _client = Client.initailizeClient();

  @override
  StorageState get initialState => new Initial();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StartSearch) {
      final QueryOptions options = QueryOptions(
        documentNode: gql(search), // this is the query string you just created
        variables: {
          'key': event.key,
        },
      );
      final results = await _client.query(options);
      if (results.hasException) {
        yield SearchError(results.exception);
        return;
      }
      final List<dynamic> items = results.data['search']['items'];
      final List<dynamic> storages = results.data['search']['storages'];

      final List<Item> listofItem = items
          .map((dynamic e) => Item(
                id: e['id'] as int,
                name: e['name'] as String,
                number: e['number'] as int,
                description: e['description'] as String,
                expirationDate: e['expirationDate'] as DateTime,
                price: e['price'] as String,
                updateDate: e['updateDate'] as DateTime,
                storage: Storage(
                  id: e['storage']['id'] as int,
                  name: e['storage']['name'] as String,
                ),
                editor: User(username: e['editor']['username'] as String),
              ))
          .toList();

      final List<Storage> listofStorage = storages
          .map((dynamic e) => Storage(
                id: e['id'],
                name: e['name'],
                description: e['description'],
              ))
          .toList();
      yield SearchResults(listofItem, listofStorage);
    }
  }
}
