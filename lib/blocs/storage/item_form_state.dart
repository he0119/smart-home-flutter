part of 'item_form_bloc.dart';

class ItemFormState extends Equatable {
  final String name;
  final bool isNameValid;
  final String number;
  final bool isNumberValid;
  final String storage;
  final bool isStorageValid;
  final String description;
  final bool isDescriptionValid;
  final String price;
  final bool isPriceValid;
  final String expirationDate;
  final bool isExpirationDateValid;
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
      isDescriptionValid: false,
      price: null,
      isPriceValid: false,
      expirationDate: null,
      isExpirationDateValid: false,
      formSubmittedSuccessfully: false,
    );
  }

  ItemFormState copyWith({
    String name,
    bool isNameValid,
    String number,
    bool isNumberValid,
    String storage,
    bool isStorageValid,
    String description,
    bool isDescriptionValid,
    String price,
    bool isPriceValid,
    String expirationDate,
    bool isExpirationDateValid,
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
        formSubmittedSuccessfully,
      ];
}
