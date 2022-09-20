library user;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class Session extends Equatable {
  final String id;
  final String ip;
  final bool isCurrent;
  final bool isValid;
  final DateTime lastActivity;
  final String userAgent;

  const Session({
    required this.id,
    required this.ip,
    required this.isCurrent,
    required this.isValid,
    required this.lastActivity,
    required this.userAgent,
  });

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  @override
  List<Object?> get props => [id, ip, isCurrent, isValid, lastActivity];

  @override
  String toString() => '$id: $ip';
}

@JsonSerializable()
class User extends Equatable {
  final String username;
  final String? email;
  final String? avatarUrl;

  const User({required this.username, required this.email, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [username];

  @override
  String toString() => username;
}
