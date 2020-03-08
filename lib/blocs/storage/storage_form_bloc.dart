import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/storage/storage_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_form_event.dart';
part 'storage_form_state.dart';

class StorageFormBloc extends Bloc<StorageFormEvent, StorageFormState> {
  final StorageBloc storageBloc;

  StorageFormBloc({@required this.storageBloc});

  @override
  StorageFormState get initialState => StorageFormState.initial();

  @override
  Stream<StorageFormState> mapEventToState(
    StorageFormEvent event,
  ) async* {
    if (event is StorageFormStarted) {
      yield state.copyWith(listofStorages: await storageRepository.storages());
    }

    if (event is NameChanged) {
      yield state.copyWith(
        name: event.name,
        isNameValid: _isNameValid(event.name),
      );
    }
    if (event is DescriptionChanged) {
      yield state.copyWith(
        description: event.description,
        isDescriptionValid: true,
      );
    }
    if (event is ParentChanged) {
      yield state.copyWith(
        parent: event.parent,
        isParentValid: _isStorageValid(event.parent),
      );
    }
    if (event is FormSubmitted) {
      if (event.isEditing) {
        storageBloc.add(
          StorageUpdateStorage(
            id: event.id,
            name: state.name,
            parentId: state.parent,
            description: state.description,
          ),
        );
      } else {
        storageBloc.add(
          StorageAddStorage(
            name: state.name,
            parentId: state.parent,
            description: state.description,
          ),
        );
      }
    }
  }

  bool _isNameValid(String name) {
    return name.isNotEmpty;
  }

  bool _isStorageValid(String storage) {
    return true;
  }
}
