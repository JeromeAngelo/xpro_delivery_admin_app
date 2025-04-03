

import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetInvoicesByCustomer extends UsecaseWithParams<List<InvoiceEntity>, String> {
  const GetInvoicesByCustomer(this._repo);
  final InvoiceRepo _repo;

  @override
  ResultFuture<List<InvoiceEntity>> call(String params) => _repo.getInvoicesByCustomerId(params);
}
