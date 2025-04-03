import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class DeleteAllPersonels implements UsecaseWithParams<bool, DeleteAllPersonelsParams> {
  final PersonelRepo _repo;

  const DeleteAllPersonels(this._repo);

  @override
  ResultFuture<bool> call(DeleteAllPersonelsParams params) => 
      _repo.deleteAllPersonels(params.personelIds);
}

class DeleteAllPersonelsParams extends Equatable {
  final List<String> personelIds;

  const DeleteAllPersonelsParams({required this.personelIds});

  @override
  List<Object> get props => [personelIds];
}
