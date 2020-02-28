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

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: int.parse(json['id']),
      name: json['name'],
      description: json['description'],
    );
  }
}
