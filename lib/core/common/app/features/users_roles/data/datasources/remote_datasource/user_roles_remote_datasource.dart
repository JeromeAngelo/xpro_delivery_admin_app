// ignore_for_file: unnecessary_type_check

import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/data/model/user_role_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class UserRolesRemoteDatasource {
  Future<List<UserRoleModel>> getAllRoles();
}

class UserRolesRemoteDatasourceImpl extends UserRolesRemoteDatasource {
  UserRolesRemoteDatasourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<UserRoleModel>> getAllRoles() async {
    try {
      final result = await _pocketBaseClient
          .collection('userRoles')
          .getFullList(expand: 'permissions', sort: '-created');

      List<UserRoleModel> userRoles = [];

      for (final record in result) {
        // Convert RecordModel to Map<String, dynamic>
        final recordData = record.toJson();

        // Add the id to the map if needed
        recordData['id'] = record.id;

        // Handle expand data if needed
        if (record.expand.isNotEmpty) {
          recordData['expand'] = {};
          record.expand.forEach((key, value) {
            recordData['expand'][key] =
                value
                    .map((item) => item is RecordModel ? item.toJson() : item)
                    .toList();
          });
        }

        userRoles.add(UserRoleModel.fromJson(recordData));
      }

      return userRoles;
    } catch (e) {
      throw ServerException(
        message: 'Failed to load all UserRoles: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
