import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteAllInvoices extends UsecaseWithParams<bool, List<String>> {
  final InvoiceRepo _repo;
  const DeleteAllInvoices(this._repo);

  @override
  ResultFuture<bool> call(List<String> params) => _repo.deleteAllInvoices(params);
}
