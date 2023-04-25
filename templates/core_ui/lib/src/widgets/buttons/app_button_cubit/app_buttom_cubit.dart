import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'app_button_state.dart';

class AppButtonCubit extends Cubit<AppButtonState> {
  AppButtonCubit() : super(AppButtonInitial());

  void setLoadingState() {
    emit(AppButtonLoading());
  }

  void setErrorState() {
    emit(AppButtonError());
  }

  void setInitialState() {
    emit(AppButtonInitial());
  }

  void setSuccessState() {
    emit(AppButtonSuccess());
  }
}
