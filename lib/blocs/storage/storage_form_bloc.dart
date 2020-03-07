import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_form_event.dart';
part 'storage_form_state.dart';

class StorageFormBloc extends Bloc<StorageFormEvent, StorageFormState> {
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
        await storageRepository.updateStorage(
          id: event.id,
          name: state.name,
          parentId: state.parent,
          description: state.description,
        );
      } else {
        await storageRepository.addStorage(
          name: state.name,
          parentId: state.parent,
          description: state.description,
        );
      }
      yield state.copyWith(
        formSubmittedSuccessfully: true,
      );
    }
  }

  bool _isNameValid(String name) {
    return name.isNotEmpty;
  }

  bool _isStorageValid(String storage) {
    return true;
  }
}
