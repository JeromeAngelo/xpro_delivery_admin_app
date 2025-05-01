import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart' show ReturnEntity;
import 'package:equatable/equatable.dart';

abstract class ReturnState extends Equatable {
  const ReturnState();
  
  @override
  List<Object?> get props => [];
}

// Existing states
class ReturnInitial extends ReturnState {
  const ReturnInitial();
}

class ReturnLoading extends ReturnState {
  const ReturnLoading();
}

class ReturnLoaded extends ReturnState {
  final List<ReturnEntity> returns;
  const ReturnLoaded(this.returns);
  
  @override
  List<Object?> get props => [returns];
}

class ReturnByCustomerLoaded extends ReturnState {
  final ReturnEntity returnItem;
  const ReturnByCustomerLoaded(this.returnItem);
  
  @override
  List<Object?> get props => [returnItem];
}

class ReturnError extends ReturnState {
  final String message;
  const ReturnError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// New states for CRUD operations
class AllReturnsLoaded extends ReturnState {
  final List<ReturnEntity> returns;
  const AllReturnsLoaded(this.returns);
  
  @override
  List<Object?> get props => [returns];
}

class ReturnCreated extends ReturnState {
  final ReturnEntity returnItem;
  const ReturnCreated(this.returnItem);
  
  @override
  List<Object?> get props => [returnItem];
}

class ReturnUpdated extends ReturnState {
  final ReturnEntity returnItem;
  const ReturnUpdated(this.returnItem);
  
  @override
  List<Object?> get props => [returnItem];
}

class ReturnDeleted extends ReturnState {
  final String id;
  const ReturnDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class ReturnsDeleted extends ReturnState {
  final List<String> ids;
  const ReturnsDeleted(this.ids);
  
  @override
  List<Object?> get props => [ids];
}
