import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:notes_apk/screens/login_screen.dart';
import 'package:notes_apk/screens/signUp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              final FirebaseAuth auth = FirebaseAuth.instance;
              User? user = auth.currentUser;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => NotesListBloc(NotesListRepository())..add(FetchNoteListEvent()),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.appTextColor,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Create an account so you can explore all the \n existing jobs",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.appTextColor,fontSize: 14, fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 30),
                      CustomTextField(
                        controller: emailController,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? "Please enter your email" : null,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        label: "Password",
                        obscureText: true,
                        validator: (value) => value!.length < 8
                            ? "Password must be at least 8 characters"
                            : null,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: confirmPasswordController,
                        label: "Confirm Password",
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm password";
                          } else if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          } else if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      state is AuthLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              text: "Sign Up",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<AuthBloc>(context).add(
                                    SignUpEvent(
                                      emailController.text,
                                      passwordController.text,
                                    ),
                                  );
                                }
                              },
                            ),
                      SizedBox(height: 10,),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account",
                          style: TextStyle(
                            color: AppColors.appTextColor,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
