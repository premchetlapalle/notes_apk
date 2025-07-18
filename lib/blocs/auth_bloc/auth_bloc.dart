import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_event.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_state.dart';
import 'package:notes_apk/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent , AuthState>{
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()){

    on<SignInEvent>((event , emit) async{
      emit(AuthLoading());
      try{
        await authRepository.signIn(event.email, event.password);
        emit(Authenticated());
      } catch (e){
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpEvent>((event , emit) async{
      emit(AuthLoading());
      try{
        await authRepository.signUp(event.email, event.password);
        emit(Authenticated());
      } catch (e){
        emit(AuthError(e.toString()));
      }
    });

    on<IfAuthEvent>((event, emit) async {
      if (authRepository.isUserLoggedIn()) {
        emit(Authenticated());
      } else {
        emit(AuthInitial());
      }
    });

    on<SignOutEvent>((event , emit) async{
      await authRepository.signOut();
      emit(AuthInitial());
    });

  }
}
