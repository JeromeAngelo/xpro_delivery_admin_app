
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/enums/user_role.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class SetRoleParams {
  const SetRoleParams({
    required this.id,
    required this.newRole,
  });

  final String id;
  final UserRole newRole;
}

class SetRole extends UsecaseWithParams<void, SetRoleParams> {
  const SetRole(this._repo);

  final PersonelRepo _repo;

  @override
  ResultFuture<void> call(SetRoleParams params) async {
    return _repo.setRole(params.id, params.newRole);
  }
}
