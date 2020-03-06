part of 'item_form_bloc.dart';

class ItemFormState extends Equatable {
  final String name;
  final bool isNameValid;
  final String number;
  final bool isNumberValid;
  final Storage storage;
  final bool isStorageValid;
  final String description;
  final bool isDescriptionValid;
  final String price;
  final bool isPriceValid;
  final DateTime expirationDate;
  final bool isExpirationDateValid;
  final List<Storage> listofStorages;
  final Item editedItem;
  final bool formSubmittedSuccessfully;

  bool get isFormValid =>
      isNameValid &&
      isNumberValid &&
      isStorageValid &&
      isDescriptionValid &&
      isPriceValid &&
      isExpirationDateValid;

  const ItemFormState({
    @required this.name,
    @required this.isNameValid,
    @required this.number,
    @required this.isNumberValid,
    @required this.storage,
    @required this.isStorageValid,
    @required this.description,
    @required this.isDescriptionValid,
    @required this.price,
    @required this.isPriceValid,
    @required this.expirationDate,
    @required this.isExpirationDateValid,
    @required this.listofStorages,
    @required this.editedItem,
    @required this.formSubmittedSuccessfully,
  });

  factory ItemFormState.initial() {
    return ItemFormState(
      name: '',
      isNameValid: false,
      number: '1',
      isNumberValid: false,
      storage: null,
      isStorageValid: false,
      description: null,
      isDescriptionValid: true,
      price: null,
      isPriceValid: true,
      expirationDate: null,
      isExpirationDateValid: true,
      listofStorages: [],
      editedItem: null,
      formSubmittedSuccessfully: false,
    );
  }

  ItemFormState copyWith({
    String name,
    bool isNameValid,
    String number,
    bool isNumberValid,
    Storage storage,
    bool isStorageValid,
    String description,
    bool isDescriptionValid,
    String price,
    bool isPriceValid,
    DateTime expirationDate,
    bool isExpirationDateValid,
    List<Storage> listofStorages,
    Item editedItem,
    bool formSubmittedSuccessfully,
  }) {
    return ItemFormState(
      name: name ?? this.name,
      isNameValid: isNameValid ?? this.isNameValid,
      number: number ?? this.number,
      isNumberValid: isNumberValid ?? this.isNumberValid,
      storage: storage ?? this.storage,
      isStorageValid: isStorageValid ?? this.isStorageValid,
      description: description ?? this.description,
      isDescriptionValid: isDescriptionValid ?? this.isDescriptionValid,
      price: price ?? this.price,
      isPriceValid: isPriceValid ?? this.isPriceValid,
      expirationDate: expirationDate ?? this.expirationDate,
      isExpirationDateValid:
          isExpirationDateValid ?? this.isExpirationDateValid,
      listofStorages: listofStorages ?? this.listofStorages,
      editedItem: editedItem ?? this.editedItem,
      formSubmittedSuccessfully:
          formSubmittedSuccessfully ?? this.formSubmittedSuccessfully,
    );
  }

  @override
  List<Object> get props => [
        name,
        isNameValid,
        number,
        isNumberValid,
        storage,
        isStorageValid,
        description,
        isDescriptionValid,
        price,
        isPriceValid,
        expirationDate,
        isExpirationDateValid,
        listofStorages,
        formSubmittedSuccessfully,
      ];
}
