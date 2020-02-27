part of 'models.dart';

class Storage {
  const Storage({
    this.id,
    this.name,
    this.parent,
    this.description,
  });

  final int id;
  final String name;
  final Storage parent;
  final String description;
}
