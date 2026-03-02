// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  profilePicture: json['profilePicture'] as String?,
  profileCompleted: json['profileCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'profilePicture': instance.profilePicture,
  'profileCompleted': instance.profileCompleted,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.sme: 'sme',
  UserRole.investor: 'investor',
};
