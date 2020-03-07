part of 'storage_form_bloc.dart';

class StorageFormState extends Equatable {
  final String name;
  final bool isNameValid;
  final String parent;
  final bool isParentValid;
  final String description;
  final bool isDescriptionValid;
  final List<Storage> listofStorages;
  final bool formSubmittedSuccessfully;

  bool get isFormValid => isNameValid && isParentValid && isDescriptionValid;

  const StorageFormState({
    @required this.name,
    @required this.isNameValid,
    @required this.parent,
    @required this.isParentValid,
    @required this.description,
    @required this.isDescriptionValid,
    @required this.listofStorages,
    @required this.formSubmittedSuccessfully,
  });

  factory StorageFormState.initial() {
    return StorageFormState(
      name: '',
      isNameValid: false,
      parent: null,
      isParentValid: false,
      description: null,
      isDescriptionValid: true,
      listofStorages: [],
      formSubmittedSuccessfully: false,
    );
  }

  StorageFormState copyWith({
    String name,
    bool isNameValid,
    String parent,
    bool isParentValid,
    String description,
    bool isDescriptionValid,
    List<Storage> listofStorages,
    bool formSubmittedSuccessfully,
  }) {
    return StorageFormState(
      name: name ?? this.name,
      isNameValid: isNameValid ?? this.isNameValid,
      parent: parent ?? this.parent,
      isParentValid: isParentValid ?? this.isParentValid,
      description: description ?? this.description,
      isDescriptionValid: isDescriptionValid ?? this.isDescriptionValid,
      listofStorages: listofStorages ?? this.listofStorages,
      formSubmittedSuccessfully:
          formSubmittedSuccessfully ?? this.formSubmittedSuccessfully,
    );
  }

  @override
  List<Object> get props => [
        name,
        isNameValid,
        parent,
        isParentValid,
        description,
        isDescriptionValid,
        listofStorages,
        formSubmittedSuccessfully,
      ];
}
