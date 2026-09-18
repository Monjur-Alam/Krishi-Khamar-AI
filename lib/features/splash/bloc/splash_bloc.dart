import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object?> get props => [];
}

class SplashStarted extends SplashEvent {
  const SplashStarted();
}

class SplashState extends Equatable {
  const SplashState({this.progress = 0, this.completed = false});
  final double progress;
  final bool completed;
  @override
  List<Object?> get props => [progress, completed];
}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(SplashState(progress: i / 10));
    }
    emit(const SplashState(progress: 1, completed: true));
  }
}
