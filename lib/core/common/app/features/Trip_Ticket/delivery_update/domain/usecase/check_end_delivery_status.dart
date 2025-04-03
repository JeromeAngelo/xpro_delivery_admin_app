
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class CheckEndDeliverStatus extends UsecaseWithParams<DataMap, String> {
  const CheckEndDeliverStatus(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<DataMap> call(String params) => _repo.checkEndDeliverStatus(params);
  
}

