import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/entity/invoice_preset_group_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/repo/invoice_preset_group_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllInvoicePresetGroups extends UsecaseWithoutParams<List<InvoicePresetGroupEntity>> {
  const GetAllInvoicePresetGroups(this._repo);

  final InvoicePresetGroupRepo _repo;

  @override
  ResultFuture<List<InvoicePresetGroupEntity>> call() async {
    return _repo.getAllInvoicePresetGroups();
  }
}
