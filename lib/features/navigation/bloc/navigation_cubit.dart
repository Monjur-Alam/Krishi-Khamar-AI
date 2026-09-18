import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavState extends Equatable {
  const NavState(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class NavigationCubit extends Cubit<NavState> {
  NavigationCubit() : super(const NavState(0));

  void setTab(int index) => emit(NavState(index));
}
