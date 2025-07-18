import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_event.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_state.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_bloc.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_event.dart';
import 'package:notes_apk/core/themes/app_colors.dart';
import 'package:notes_apk/core/utils/custom_button.dart';
import 'package:notes_apk/core/utils/custom_text_field.dart';
import 'package:notes_apk/repository/notes_list_repository.dart';
import 'package:notes_apk/screens/home_screen.dart';
import 'package:notes_apk/screens/signUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              final FirebaseAuth auth = FirebaseAuth.instance;
              User? user = auth.currentUser;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => NotesListBloc(NotesListRepository())
                      ..add(FetchNoteListEvent()),
                    child: const HomeScreen(),
                  ),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Login here',
                        style: TextStyle(
                          color: AppColors.appTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Welcome back, your presence was\n truly missed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: AppColors.appTextColor
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: emailController,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value!.isEmpty ? "Please enter your email" : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        label: "Password",
                        obscureText: true,
                        validator: (value) => value!.length < 8
                            ? "Password must be at least 8 characters"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Text(
                      //     "Forgot your password?",
                      //     style: TextStyle(
                      //       color: AppColors.appIconColor,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //       fontFamily: 'Poppins',
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 32),
                      state is AuthLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                        text: "Sign in",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<AuthBloc>(context).add(
                              SignInEvent(
                                emailController.text,
                                passwordController.text,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          "Create new account",
                          style: TextStyle(
                            color: AppColors.appTextColor,
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
