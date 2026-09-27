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

class ProfileState extends Equatable {
  const ProfileState({this.profile});

  final UserProfile? profile;

  ProfileState copyWith({UserProfile? profile}) {
    return ProfileState(profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [profile];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileStarted>((event, emit) {
      emit(const ProfileState(profile: DummyData.profile));
    });
  }
}
