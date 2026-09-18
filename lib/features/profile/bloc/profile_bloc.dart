import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileShowSettings extends ProfileEvent {
  const ProfileShowSettings();
}

class ProfileShowMain extends ProfileEvent {
  const ProfileShowMain();
}

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.showSettings = false,
  });

  final UserProfile? profile;
  final bool showSettings;

  ProfileState copyWith({
    UserProfile? profile,
    bool? showSettings,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      showSettings: showSettings ?? this.showSettings,
    );
  }

  @override
  List<Object?> get props => [profile, showSettings];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileStarted>((event, emit) {
      emit(const ProfileState(profile: DummyData.profile));
    });
    on<ProfileShowSettings>((event, emit) {
      emit(state.copyWith(showSettings: true));
    });
    on<ProfileShowMain>((event, emit) {
      emit(state.copyWith(showSettings: false));
    });
  }
}
