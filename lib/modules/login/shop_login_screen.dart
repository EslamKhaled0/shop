import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/layout/shop_layout.dart';
import 'package:shop/modules/login/cubit/cubit.dart';
import 'package:shop/modules/login/cubit/states.dart';
import 'package:shop/modules/register/shop_register_screen.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/network/local/cache_helper.dart';

class ShopLoginScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ShopLoginCubit(),
      child: BlocConsumer<ShopLoginCubit, ShopLoginStates>(
        listener: (context, state) {
          if (state is ShopLoginSuccessState) {
            if (state.loginModel.status == true) {
              print(state.loginModel.message);
              print(state.loginModel.data!.token);

              CacheHelper.saveData(
                key: 'token',
                value: state.loginModel.data!.token,
              ).then((value) {
                token = state.loginModel.data!.token!;

                navigateAndFinish(
                  context,
                  ShopLayout(),
                );
              });
            } else {
              print(state.loginModel.message);

              showToast(
                text: "${state.loginModel.message}",
                state: ToastStates.ERROR,
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOGIN',
                          style:
                              Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                        Text(
                          'Login now to browse our hot offers',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        defaultFormField(
                          controller: emailController,
                          type: TextInputType.emailAddress,
                          validate: (value) {
                            if (value != null && value.isEmpty) {
                              return 'please enter your email address';
                            } else {
                              return null;
                            }
                          },
                          label: 'Email Address',
                          prefix: Icons.email_outlined,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          suffix: ShopLoginCubit.get(context).suffix,
                          onSubmit: (value) {
                            if (formKey.currentState!.validate()) {
                              ShopLoginCubit.get(context).userLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          isPassword: ShopLoginCubit.get(context).isPassword,
                          suffixPressed: () {
                            ShopLoginCubit.get(context)
                                .changePasswordVisibility();
                          },
                          validate: (value) {
                            if (value != null && value.isEmpty) {
                              return 'password is too short';
                            }
                          },
                          label: 'Password',
                          prefix: Icons.lock_outline,
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        ConditionalBuilder(
                          condition: state is! ShopLoginLoadingState,
                          builder: (context) => defaultButton(
                            function: () {
                              if (formKey.currentState!.validate()) {
                                ShopLoginCubit.get(context).userLogin(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                            text: 'login',
                            isUpperCase: true,
                          ),
                          fallback: (context) =>
                              Center(child: CircularProgressIndicator()),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                            ),
                            defaultTextButton(
                              function: () {
                                navigateTo(
                                  context,
                                  ShopRegisterScreen(),
                                );
                              },
                              text: 'register',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
