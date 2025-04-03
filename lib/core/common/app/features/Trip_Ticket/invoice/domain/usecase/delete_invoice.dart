import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteInvoice extends UsecaseWithParams<bool, String> {
  final InvoiceRepo _repo;
  const DeleteInvoice(this._repo);

  @override
  ResultFuture<bool> call(String params) => _repo.deleteInvoice(params);
}
