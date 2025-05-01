import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/datasource/remote_datasource/delivery_team_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/repo/delivery_team_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/repo/delivery_team_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/usecase/assign_delivery_team_to_trip.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/usecase/create_delivery_team.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/usecase/delete_delivery_team.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/usecase/load_all_delivery_team.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/usecase/update_delivery_team.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/presentation/bloc/delivery_team_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/datasource/remote_datasource/personel_remote_data_source.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/repo/personels_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/create_personels.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/delete_all_personels.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/delete_personels.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/get_personels.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/load_personels_by_delivery_team.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/load_personels_by_trip_Id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/set_role.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/domain/usecase/update_personels.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/data/datasource/remote_datasource/vehicle_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/data/repo/vehicle_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/create_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/delete_all_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/delete_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/get_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/load_vehicle_by_delivery_team_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/load_vehicle_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/update_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/datasource/remote_datasource/completed_customer_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/repo/completed_customer_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/create_compeleted_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/delete_all_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/delete_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_all_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_completed_customer_by_id_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/update_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/datasource/remote_datasource/customer_remote_data_source.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/repo/customer_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/calculate_customer_total_time.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/create_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/delete_all_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/delete_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_all_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_customersLocation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/update_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/datasource/remote_datasource/delivery_update_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/repo/delivery_update_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/check_end_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/complete_delivery_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/create_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/create_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/delete_all_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/delete_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/get_all_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/get_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/itialized_pending_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_queue_remarks.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/presentation/bloc/delivery_update_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/datasource/remote_data_source/invoice_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/repo/invoice_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/create_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/delete_all_invoices.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/delete_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_per_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_per_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoices_by_completed_customer_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/update_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/data/datasource/remote_datasource/product_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/data/repo/product_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/add_to_return_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/confirm_delivery_products.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/create_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/delete_all_products.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/delete_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/get_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/get_products_by_invoice_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_product_quantities.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_return_reason_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_status_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/datasource/remote_datasource/return_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/repo/return_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/create_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/delete_all_return.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/delete_return.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_all_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_return_by_customerId.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_return_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/update_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/datasource/remote_datasource/transaction_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/repo/transaction_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/create_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/delete_all_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/delete_transaction.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/delete_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/generate_pdf.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_all_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_date_range_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_id_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/process_complete_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/update_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/datasource/remote_datasource/trip_remote_datasurce.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/repo/trip_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/create_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/delete_all_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/delete_trip_ticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/get_all_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/get_tripticket_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/search_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/update_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/data/datasources/remote_datasource/trip_update_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/data/repo/trip_update_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/create_trip_updates.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/delete_all_trip_updates.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/delete_trip_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/get_all_trip_updates.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/get_trip_updates.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/update_trip_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/datasources/remote_datasource/undeliverable_customer_remote_datasrc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/repo/undeliverable_customer_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/create_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/delete_all_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/delete_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_all_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_undeliverable_customer_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/set_undeliverable_reason.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/update_undeliverable_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/datasource/remote_datasource/checklist_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/repo/checklist_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/check_Item.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/create_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/delete_all_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/delete_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/get_all_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/load_checklist_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/update_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/data/repo/auth_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_all_user.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_token.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_user_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/sign_in.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/sign_out.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/data/datasources/remote_datasource/end_trip_checklist_remote_data_src.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/data/repo/end_trip_checklist_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/check_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/create_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/delete_all_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/delete_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/generate_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/get_all_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/load_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/update_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/presentation/bloc/end_trip_checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/data/datasources/remote_datasource/end_trip_otp_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/data/repo/end_trip_otp_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/create_end_trip_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/delete_all_end_trip_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/delete_end_trip_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/end_otp_verify.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/get_all_end_trip_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/get_end_trip_generated.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/load_end_trip_otp_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/load_end_trip_otp_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/usecases/update_end_trip_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/datasources/remote_data_source/auth_remote_data_src.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/repo/auth_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/create_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/get_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/update_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/data/datasource/remote_data_source/otp_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/data/repo/otp_repo_impl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/create_otp.dart'
    show CreateOtp;
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/delete_all_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/delete_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/get_all_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/get_generated_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/load_otp_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/load_otp_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/update_otp.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/verify_in_transit.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/usecases/veryfy_in_end_delivery.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/presentation/bloc/otp_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

final sl = GetIt.instance;
final pb = PocketBase('http://192.168.1.118:8090');

Future<void> init() async {
  await initAuth();
  await initGeneralAuth();
  await initVehicle();
  await initPersonels();
  await initDeliveryTeam();
  await initChecklist();
  await initEndTripChecklist();
  await initEndTripOtp();
  await initFirstOtp();
  await initCompletedCustomer();
  await initCustomer();
  await initInvoices();
  await initProducts();
  await initReturns(); // Add this line
  await initDeliveryUpdateStatus();
  await initTransactions();
  await initTripUpdate();
  await initUndeliveredCustomer();
  await initTrip();
}

Future<void> initAuth() async {
  //BLoC
  sl.registerLazySingleton(
    () => AuthBloc(
      signInUsecase: sl(),
      signOutUsecase: sl(),
      getTokenUsecase: sl(),
      getAllUsersUsecase: sl(),
      getUserByIdUsecase: sl(),
    ),
  );

  //usecase
  sl.registerLazySingleton(() => SignInUsecase(sl()));
  sl.registerLazySingleton(() => SignOutUsecase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUsecase(sl()));
  sl.registerLazySingleton(() => GetTokenUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(pocketBaseClient: sl()),
  );

  // External
  sl.registerLazySingleton(() => pb);
}

Future<void> initGeneralAuth() async {
  //BLoC
  sl.registerLazySingleton(
    () => GeneralUserBloc(
      getAllUsers: sl(),
      createUser: sl(),
      updateUser: sl(),
      deleteUser: sl(),
      deleteAllUsers: sl(),
    ),
  );

  //usecases
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));
  sl.registerLazySingleton(() => DeleteAllUsers(sl()));

  sl.registerLazySingleton<GeneralUserRepo>(() => GeneralUserRepoImpl(sl()));
  sl.registerLazySingleton<GeneralUserRemoteDataSource>(
    () => GeneralUserRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initDeliveryTeam() async {
  // BLoC
  sl.registerLazySingleton(
    () => DeliveryTeamBloc(
      tripBloc: sl<TripBloc>(),
      personelBloc: sl<PersonelBloc>(),
      vehicleBloc: sl<VehicleBloc>(),
      checklistBloc: sl<ChecklistBloc>(),

      loadAllDeliveryTeam: sl(),
      assignDeliveryTeamToTrip: sl(),
      createDeliveryTeam: sl(),
      updateDeliveryTeam: sl(),
      deleteDeliveryTeam: sl(),
    ),
  );

  // Usecases

  sl.registerLazySingleton(() => LoadAllDeliveryTeam(sl()));
  sl.registerLazySingleton(() => AssignDeliveryTeamToTrip(sl()));
  sl.registerLazySingleton(() => CreateDeliveryTeam(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryTeam(sl()));
  sl.registerLazySingleton(() => DeleteDeliveryTeam(sl()));

  // Repository
  sl.registerLazySingleton<DeliveryTeamRepo>(() => DeliveryTeamRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<DeliveryTeamDatasource>(
    () => DeliveryTeamDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initVehicle() async {
  // BLoC
  sl.registerLazySingleton(
    () => VehicleBloc(
      getVehicles: sl(),
      loadVehicleByTripId: sl(),
      loadVehicleByDeliveryTeam: sl(),
      createVehicle: sl(),
      updateVehicle: sl(),
      deleteVehicle: sl(),
      deleteAllVehicles: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetVehicle(sl()));
  sl.registerLazySingleton(() => LoadVehicleByTripId(sl()));
  sl.registerLazySingleton(() => LoadVehicleByDeliveryTeam(sl()));
  sl.registerLazySingleton(() => CreateVehicle(sl()));
  sl.registerLazySingleton(() => UpdateVehicle(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => DeleteAllVehicles(sl()));

  // Repository
  sl.registerLazySingleton<VehicleRepo>(() => VehicleRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<VehicleRemoteDatasource>(
    () => VehicleRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initPersonels() async {
  // BLoC
  sl.registerLazySingleton(
    () => PersonelBloc(
      getPersonels: sl(),
      setRole: sl(),
      loadPersonelsByTripId: sl(),
      loadPersonelsByDeliveryTeam: sl(),
      createPersonel: sl(),
      updatePersonel: sl(),
      deletePersonel: sl(),
      deleteAllPersonels: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetPersonels(sl()));
  sl.registerLazySingleton(() => SetRole(sl()));
  sl.registerLazySingleton(() => LoadPersonelsByTripId(sl()));
  sl.registerLazySingleton(() => LoadPersonelsByDeliveryTeam(sl()));
  sl.registerLazySingleton(() => CreatePersonel(sl()));
  sl.registerLazySingleton(() => UpdatePersonel(sl()));
  sl.registerLazySingleton(() => DeletePersonel(sl()));
  sl.registerLazySingleton(() => DeleteAllPersonels(sl()));

  // Repository
  sl.registerLazySingleton<PersonelRepo>(() => PersonelsRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<PersonelRemoteDataSource>(
    () => PersonelRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initChecklist() async {
  // BLoC
  sl.registerLazySingleton(
    () => ChecklistBloc(
      checkItem: sl(),
      loadChecklistByTripId: sl(),
      getAllChecklists: sl(),
      createChecklistItem: sl(),
      updateChecklistItem: sl(),
      deleteChecklistItem: sl(),
      deleteAllChecklistItems: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => CheckItem(sl()));
  sl.registerLazySingleton(() => LoadChecklistByTripId(sl()));
  sl.registerLazySingleton(() => GetAllChecklists(sl()));
  sl.registerLazySingleton(() => CreateChecklistItem(sl()));
  sl.registerLazySingleton(() => UpdateChecklistItem(sl()));
  sl.registerLazySingleton(() => DeleteChecklistItem(sl()));
  sl.registerLazySingleton(() => DeleteAllChecklistItems(sl()));

  // Repository
  sl.registerLazySingleton<ChecklistRepo>(() => ChecklistRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ChecklistDatasource>(
    () => ChecklistDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initFirstOtp() async {
  // BLoC
  sl.registerLazySingleton(
    () => OtpBloc(
      loadOtpByTripId: sl(),
      verifyInTransit: sl(),
      verifyEndDelivery: sl(),
      getGeneratedOtp: sl(),
      loadOtpById: sl(),
      getAllOtps: sl(),
      createOtp: sl(),
      updateOtp: sl(),
      deleteOtp: sl(),
      deleteAllOtps: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => LoadOtpByTripId(sl()));
  sl.registerLazySingleton(() => VerifyInTransit(sl()));
  sl.registerLazySingleton(() => VerifyInEndDelivery(sl()));
  sl.registerLazySingleton(() => GetGeneratedOtp(sl()));
  sl.registerLazySingleton(() => LoadOtpById(sl()));
  sl.registerLazySingleton(() => GetAllOtps(sl()));
  sl.registerLazySingleton(() => CreateOtp(sl()));
  sl.registerLazySingleton(() => UpdateOtp(sl()));
  sl.registerLazySingleton(() => DeleteOtp(sl()));
  sl.registerLazySingleton(() => DeleteAllOtps(sl()));

  // Repository
  sl.registerLazySingleton<OtpRepo>(() => OtpRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<OtpRemoteDataSource>(
    () => OtpRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initEndTripChecklist() async {
  // BLoC
  sl.registerLazySingleton(
    () => EndTripChecklistBloc(
      generateEndTripChecklist: sl(),
      checkEndTripChecklist: sl(),
      loadEndTripChecklist: sl(),
      getAllEndTripChecklists: sl(),
      createEndTripChecklistItem: sl(),
      updateEndTripChecklistItem: sl(),
      deleteEndTripChecklistItem: sl(),
      deleteAllEndTripChecklistItems: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GenerateEndTripChecklist(sl()));
  sl.registerLazySingleton(() => CheckEndTripChecklist(sl()));
  sl.registerLazySingleton(() => LoadEndTripChecklist(sl()));
  sl.registerLazySingleton(() => GetAllEndTripChecklists(sl()));
  sl.registerLazySingleton(() => CreateEndTripChecklistItem(sl()));
  sl.registerLazySingleton(() => UpdateEndTripChecklistItem(sl()));
  sl.registerLazySingleton(() => DeleteEndTripChecklistItem(sl()));
  sl.registerLazySingleton(() => DeleteAllEndTripChecklistItems(sl()));

  // Repository
  sl.registerLazySingleton<EndTripChecklistRepo>(
    () => EndTripChecklistRepoImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<EndTripChecklistRemoteDataSource>(
    () => EndTripChecklistRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initEndTripOtp() async {
  // BLoC
  sl.registerLazySingleton(
    () => EndTripOtpBloc(
      verifyEndTripOtp: sl(),
      getGeneratedEndTripOtp: sl(),
      loadEndTripOtpById: sl(),
      loadEndTripOtpByTripId: sl(),
      getAllEndTripOtps: sl(),
      createEndTripOtp: sl(),
      updateEndTripOtp: sl(),
      deleteEndTripOtp: sl(),
      deleteAllEndTripOtps: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => EndOTPVerify(sl()));
  sl.registerLazySingleton(() => GetEndTripGeneratedOtp(sl()));
  sl.registerLazySingleton(() => LoadEndTripOtpById(sl()));
  sl.registerLazySingleton(() => LoadEndTripOtpByTripId(sl()));
  sl.registerLazySingleton(() => GetAllEndTripOtps(sl()));
  sl.registerLazySingleton(() => CreateEndTripOtp(sl()));
  sl.registerLazySingleton(() => UpdateEndTripOtp(sl()));
  sl.registerLazySingleton(() => DeleteEndTripOtp(sl()));
  sl.registerLazySingleton(() => DeleteAllEndTripOtps(sl()));

  // Repository
  sl.registerLazySingleton<EndTripOtpRepo>(() => EndTripOtpRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<EndTripOtpRemoteDataSource>(
    () => EndTripOtpRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initCustomer() async {
  // BLoC
  sl.registerLazySingleton(
    () => CustomerBloc(
      invoiceBloc: sl<InvoiceBloc>(),
      deliveryUpdateBloc: sl<DeliveryUpdateBloc>(),
      getCustomer: sl(),
      getCustomersLocation: sl(),
      calculateCustomerTotalTime: sl(),
      getAllCustomers: sl(),
      createCustomer: sl(),
      updateCustomer: sl(),
      deleteCustomer: sl(),
      deleteAllCustomers: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetCustomer(sl()));
  sl.registerLazySingleton(() => GetCustomersLocation(sl()));
  sl.registerLazySingleton(() => CalculateCustomerTotalTime(sl()));
  sl.registerLazySingleton(() => GetAllCustomers(sl()));
  sl.registerLazySingleton(() => CreateCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));
  sl.registerLazySingleton(() => DeleteAllCustomers(sl()));

  // Repository
  sl.registerLazySingleton<CustomerRepo>(() => CustomerRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initCompletedCustomer() async {
  // BLoC
  sl.registerLazySingleton(
    () => CompletedCustomerBloc(
      invoiceBloc: sl<InvoiceBloc>(),
      getCompletedCustomers: sl(),
      getCompletedCustomerById: sl(),
      getAllCompletedCustomers: sl(),
      createCompletedCustomer: sl(),
      updateCompletedCustomer: sl(),
      deleteCompletedCustomer: sl(),
      deleteAllCompletedCustomers: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetCompletedCustomer(sl()));
  sl.registerLazySingleton(() => GetCompletedCustomerById(sl()));
  sl.registerLazySingleton(() => GetAllCompletedCustomers(sl()));
  sl.registerLazySingleton(() => CreateCompletedCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCompletedCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCompletedCustomer(sl()));
  sl.registerLazySingleton(() => DeleteAllCompletedCustomers(sl()));

  // Repository
  sl.registerLazySingleton<CompletedCustomerRepo>(
    () => CompletedCustomerRepoImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<CompletedCustomerRemoteDatasource>(
    () => CompletedCustomerRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initDeliveryUpdateStatus() async {
  // BLoC
  sl.registerLazySingleton(
    () => DeliveryUpdateBloc(
      getDeliveryStatusChoices: sl(),
      updateDeliveryStatus: sl(),
      completeDelivery: sl(),
      checkEndDeliverStatus: sl(),
      initializePendingStatus: sl(),
      createDeliveryStatus: sl(),
      updateQueueRemarks: sl(),
      getAllDeliveryUpdates: sl(),
      createDeliveryUpdate: sl(),
      updateDeliveryUpdate: sl(),
      deleteDeliveryUpdate: sl(),
      deleteAllDeliveryUpdates: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetDeliveryStatusChoices(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryStatus(sl()));
  sl.registerLazySingleton(() => CompleteDelivery(sl()));
  sl.registerLazySingleton(() => CheckEndDeliverStatus(sl()));
  sl.registerLazySingleton(() => InitializePendingStatus(sl()));
  sl.registerLazySingleton(() => CreateDeliveryStatus(sl()));
  sl.registerLazySingleton(() => UpdateQueueRemarks(sl()));

  // New usecases
  sl.registerLazySingleton(() => GetAllDeliveryUpdates(sl()));
  sl.registerLazySingleton(() => CreateDeliveryUpdate(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryUpdate(sl()));
  sl.registerLazySingleton(() => DeleteDeliveryUpdate(sl()));
  sl.registerLazySingleton(() => DeleteAllDeliveryUpdates(sl()));

  // Repository
  sl.registerLazySingleton<DeliveryUpdateRepo>(
    () => DeliveryUpdateRepoImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<DeliveryUpdateDatasource>(
    () => DeliveryUpdateDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initInvoices() async {
  // BLoC
  sl.registerLazySingleton(
    () => InvoiceBloc(
      productsBloc: sl<ProductsBloc>(),
      getInvoices: sl(),
      getInvoicesByTrip: sl(),
      getInvoicesByCustomer: sl(),
      createInvoice: sl(),
      updateInvoice: sl(),
      deleteInvoice: sl(),
      deleteAllInvoices: sl(),
      getInvoiceById: sl(),
      getInvoicesByCompletedCustomerId: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetInvoice(sl()));
  sl.registerLazySingleton(() => GetInvoiceById(sl()));
  sl.registerLazySingleton(() => GetInvoicesByCompletedCustomerId(sl()));

  sl.registerLazySingleton(() => GetInvoicesByTrip(sl()));
  sl.registerLazySingleton(() => GetInvoicesByCustomer(sl()));
  sl.registerLazySingleton(() => CreateInvoice(sl()));
  sl.registerLazySingleton(() => UpdateInvoice(sl()));
  sl.registerLazySingleton(() => DeleteInvoice(sl()));
  sl.registerLazySingleton(() => DeleteAllInvoices(sl()));

  // Repository
  sl.registerLazySingleton<InvoiceRepo>(() => InvoiceRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<InvoiceRemoteDatasource>(
    () => InvoiceRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initProducts() async {
  // BLoC
  sl.registerLazySingleton(
    () => ProductsBloc(
      getProduct: sl(),
      getProductsByInvoice: sl(),
      updateStatusProduct: sl(),
      confirmDeliveryProducts: sl(),
      addToReturn: sl(),
      updateReturnReason: sl(),
      updateProductQuantities: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
      deleteAllProducts: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => GetProductsByInvoice(sl()));
  sl.registerLazySingleton(() => UpdateStatusProduct(sl()));
  sl.registerLazySingleton(() => ConfirmDeliveryProducts(sl()));
  sl.registerLazySingleton(() => AddToReturnUsecase(sl()));
  sl.registerLazySingleton(() => UpdateReturnReasonUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductQuantities(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => DeleteAllProducts(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepo>(() => ProductRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initReturns() async {
  // BLoC
  sl.registerLazySingleton(
    () => ReturnBloc(
      getReturns: sl(),
      getReturnByCustomerId: sl(),
      getAllReturns: sl(),
      createReturn: sl(),
      updateReturn: sl(),
      deleteReturn: sl(),
      deleteAllReturns: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetReturnUsecase(sl()));
  sl.registerLazySingleton(() => GetReturnByCustomerId(sl()));
  sl.registerLazySingleton(() => GetAllReturns(sl()));
  sl.registerLazySingleton(() => CreateReturn(sl()));
  sl.registerLazySingleton(() => UpdateReturn(sl()));
  sl.registerLazySingleton(() => DeleteReturn(sl()));
  sl.registerLazySingleton(() => DeleteAllReturns(sl()));

  // Repository
  sl.registerLazySingleton<ReturnRepo>(() => ReturnRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ReturnRemoteDatasource>(
    () => ReturnRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initTransactions() async {
  //BLoC

  sl.registerSingleton(
    () => TransactionBloc(
      createTransaction: sl(),
      deleteTransaction: sl(),
      getTransactionById: sl(),
      getTransactions: sl(),
      getTransactionsByDateRange: sl(),
      getTransactionsByCompletedCustomer: sl(),
      generateTransactionPdf: sl(),
      getAllTransactions: sl(),
      processCompleteTransaction: sl(),
      updateTransaction: sl(),
      deleteAllTransactions: sl(),
    ),
  );
  //Usecases
  sl.registerLazySingleton(() => DeleteAllTransactions(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => CreateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GenerateTransactionPdf(sl()));
  sl.registerLazySingleton(() => GetAllTransactions(sl()));
  sl.registerLazySingleton(() => GetTransactionByDateRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByCompletedCustomer(sl()));
  sl.registerLazySingleton(() => GetTransactionByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionUseCase(sl()));
  sl.registerLazySingleton(() => ProcessCompleteTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));

  //repository
  // Repository
  sl.registerLazySingleton<TransactionRepo>(() => TransactionRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initTripUpdate() async {
  // BLoC
  sl.registerLazySingleton(
    () => TripUpdatesBloc(
      getTripUpdates: sl(),
      getAllTripUpdates: sl(),
      createTripUpdate: sl(),
      updateTripUpdate: sl(),
      deleteTripUpdate: sl(),
      deleteAllTripUpdates: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetTripUpdates(sl()));
  sl.registerLazySingleton(() => GetAllTripUpdates(sl()));
  sl.registerLazySingleton(() => CreateTripUpdate(sl()));
  sl.registerLazySingleton(() => UpdateTripUpdate(sl()));
  sl.registerLazySingleton(() => DeleteTripUpdate(sl()));
  sl.registerLazySingleton(() => DeleteAllTripUpdates(sl()));

  // Repository
  sl.registerLazySingleton<TripUpdateRepo>(() => TripUpdateRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<TripUpdateRemoteDatasource>(
    () => TripUpdateRemoteDatasourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initUndeliveredCustomer() async {
  //BLoC
  sl.registerLazySingleton(
    () => UndeliverableCustomerBloc(
      getUndeliverableCustomers: sl(),
      getUndeliverableCustomerById: sl(),
      getAllUndeliverableCustomers: sl(),

      createUndeliverableCustomer: sl(),
      updateUndeliverableCustomer: sl(),
      deleteUndeliverableCustomer: sl(),
      deleteAllUndeliverableCustomers: sl(),
      setUndeliverableReason: sl(),
    ),
  );

  //Usecase
  sl.registerLazySingleton(() => GetUndeliverableCustomerById(sl()));
  sl.registerLazySingleton(() => GetUndeliverableCustomers(sl()));
  sl.registerLazySingleton(() => SetUndeliverableReason(sl()));

  sl.registerLazySingleton(() => GetAllUndeliverableCustomers(sl()));
  sl.registerLazySingleton(() => CreateUndeliverableCustomer(sl()));
  sl.registerLazySingleton(() => UpdateUndeliverableCustomer(sl()));
  sl.registerLazySingleton(() => DeleteUndeliverableCustomer(sl()));
  sl.registerLazySingleton(() => DeleteAllUndeliverableCustomers(sl()));

  //repo
  sl.registerLazySingleton<UndeliverableRepo>(
    () => UndeliverableCustomerRepoImpl(remoteDataSource: sl()),
  );
  //datasource
  sl.registerLazySingleton<UndeliverableCustomerRemoteDataSource>(
    () => UndeliverableCustomerRemoteDataSourceImpl(pocketBaseClient: sl()),
  );
}

Future<void> initTrip() async {
  // BLoC
  sl.registerLazySingleton(
    () => TripBloc(
      getAllTripTickets: sl(),
      createTripTicket: sl(),
      searchTripTickets: sl(),
      getTripTicketById: sl(),
      updateTripTicket: sl(),
      deleteTripTicket: sl(),
      deleteAllTripTickets: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetAllTripTickets(sl()));
  sl.registerLazySingleton(() => CreateTripTicket(sl()));
  sl.registerLazySingleton(() => SearchTripTickets(sl()));
  sl.registerLazySingleton(() => GetTripTicketById(sl()));
  sl.registerLazySingleton(() => UpdateTripTicket(sl()));
  sl.registerLazySingleton(() => DeleteTripTicket(sl()));
  sl.registerLazySingleton(() => DeleteAllTripTickets(sl()));

  // Repository
  sl.registerLazySingleton<TripRepo>(() => TripRepoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<TripRemoteDatasurce>(
    () => TripRemoteDatasurceImpl(pocketBaseClient: sl()),
  );
}
