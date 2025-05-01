

import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class CheckItem extends UsecaseWithParams<bool, String> {
  const CheckItem(this._repo);

  final ChecklistRepo _repo;

  @override
  ResultFuture<bool> call(String params) => _repo.checkItem(params);
}

