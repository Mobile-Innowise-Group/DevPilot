part of 'app_buttom_cubit.dart';

@immutable
abstract class AppButtonState {}

class AppButtonInitial extends AppButtonState {}

class AppButtonLoading extends AppButtonState {}

class AppButtonError extends AppButtonState {}

class AppButtonSuccess extends AppButtonState {}
