import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_event.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_state.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_bloc.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_event.dart';
import 'package:notes_apk/repository/notes_list_repository.dart';
import 'package:notes_apk/screens/home_screen.dart';
import 'package:notes_apk/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status when splash screen loads
    context.read<AuthBloc>().add(IfAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => NotesListBloc(NotesListRepository())..add(FetchNoteListEvent()),
                  child: const HomeScreen(),
                ),
              ),
            );

          } else if (state is AuthInitial || state is AuthError) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: Center(
          child: Text("")
        ),
      ),
    );
  }
}
