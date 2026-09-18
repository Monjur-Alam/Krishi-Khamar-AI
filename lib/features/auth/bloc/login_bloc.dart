import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginPhoneChanged extends LoginEvent {
  const LoginPhoneChanged(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

class LoginSendOtpPressed extends LoginEvent {
  const LoginSendOtpPressed();
}

class LoginGooglePressed extends LoginEvent {
  const LoginGooglePressed();
}

class LoginState extends Equatable {
  const LoginState({
    this.phone = '',
    this.isLoading = false,
    this.authenticated = false,
  });

  final String phone;
  final bool isLoading;
  final bool authenticated;

  LoginState copyWith({
    String? phone,
    bool? isLoading,
    bool? authenticated,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
      authenticated: authenticated ?? this.authenticated,
    );
  }

  @override
  List<Object?> get props => [phone, isLoading, authenticated];
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginPhoneChanged>((e, emit) => emit(state.copyWith(phone: e.phone)));
    on<LoginSendOtpPressed>(_onSendOtp);
    on<LoginGooglePressed>(_onGoogle);
  }

  Future<void> _onSendOtp(
    LoginSendOtpPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(isLoading: false, authenticated: true));
  }

  Future<void> _onGoogle(
    LoginGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(isLoading: false, authenticated: true));
  }
}
