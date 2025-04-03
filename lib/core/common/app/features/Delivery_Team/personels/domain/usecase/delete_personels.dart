import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeletePersonel implements UsecaseWithParams<bool, String> {
  final PersonelRepo _repo;

  const DeletePersonel(this._repo);

  @override
  ResultFuture<bool> call(String personelId) => _repo.deletePersonel(personelId);
}
