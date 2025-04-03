import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/enums/product_unit.dart';
import 'package:desktop_app/core/enums/products_status.dart';
import 'package:equatable/equatable.dart';


class ProductEntity extends Equatable {
  String? id;
  String? name;
  String? description;
  double? totalAmount;
  int? case_;
  int? pcs;
  int? pack;
  int? box;
  double? pricePerCase;
  double? pricePerPc;
  ProductUnit? primaryUnit;
  ProductUnit? secondaryUnit;
  String? image;

  final InvoiceModel? invoice;
  final CustomerModel? customer;

  bool? isCase;
  bool? isPc;
  bool? isPack;
  bool? isBox;
  bool? hasReturn;
  int? unloadedProductCase;
  int? unloadedProductPc;
  int? unloadedProductPack;
  int? unloadedProductBox;
  ProductsStatus? status;
  ProductReturnReason? returnReason;

  ProductEntity({
    this.id,
    this.name,
    this.description,
    this.totalAmount,
    this.case_,
    this.pcs,
    this.pack,
    this.box,
    this.pricePerCase,
    this.pricePerPc,
    this.primaryUnit,
    this.secondaryUnit,
    this.image,
    this.hasReturn,
    this.invoice,
    this.customer,
    this.isCase,
    this.isPc,
    this.isPack,
    this.isBox,
    this.unloadedProductCase,
    this.unloadedProductPc,
    this.unloadedProductPack,
    this.unloadedProductBox,
    this.status,
    this.returnReason,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        totalAmount,
        case_,
        pcs,
        pack,
        box,
        pricePerCase,
        pricePerPc,
        primaryUnit,
        hasReturn,
        secondaryUnit,
        image,
        invoice?.id,
        customer?.id,
        isCase,
        isPc,
        isPack,
        isBox,
        unloadedProductCase,
        unloadedProductPc,
        unloadedProductPack,
        unloadedProductBox,
        status,
        returnReason,
      ];
}
