import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:mvp_proex/app/app.color.dart';
import 'package:mvp_proex/features/login/login.controller.dart';
import 'package:mvp_proex/features/login/login.repository.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:mvp_proex/features/user/user.repository.dart';
import 'package:mvp_proex/features/widgets/shared/button_submit.widget.dart';
import 'package:mvp_proex/features/widgets/shared/form_field.widget.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late UserModel userModel;
  LoginController controller = LoginController();
  Repository repository = Repository();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.token != "") {
      Navigator.of(context).pushReplacementNamed('/mapselection');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: size.width < 320 ? size.width * 0.8 : 280,
            height: size.height,
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Spacer(
                    flex: 4,
                  ),
                  const Text(
                    "Módulo\n1",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  FormFieldWidget(
                    title: "E-mail",
                    description: "Entre com seu email",
                    validator: (String value) {
                      if (value.isEmpty) return "Campo vazio";
                      if (value.length < 10) return "Campo muito pequeno";
                      if (!value.contains("@")) return "Falta @";
                      if (!value.contains("@")) return "Falta .";
                      return null;
                    },
                    controller: controller.emailEditingController,
                    onChanged: (value) {
                      userModel.email = value;
                    },
                    icon: const SizedBox(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  RxBuilder(
                    builder: (context) {
                      return FormFieldWidget(
                        title: "Senha",
                        description: "Senha do sistema",
                        validator: (value) {
                          if (value.isEmpty) return "Campo vazio";
                          return null;
                        },
                        controller: controller.passwordEditingController,
                        onChanged: (value) {
                          userModel.password = value;
                        },
                        keyboardType: TextInputType.text,
                        obscure: !controller.getIsVisible,
                        icon: IconButton(
                          icon: !controller.getIsVisible == true
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onPressed: () {
                            controller.isVisible.value =
                                !controller.getIsVisible;
                          },
                        ),
                      );
                    },
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  RxBuilder(
                    builder: (context) {
                      return controller.getIsLoading
                          ? const CircularProgressIndicator()
                          : ButtonSubmitWidget(
                              textButton: "Entrar",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.isLoading.value = true;
                                  LoginRepository()
                                      .postToken(
                                    model: userModel,
                                  )
                                      .then(
                                    (value) {
                                      if (value.contains("Erro")) {
                                        showMessageError(
                                            context: context, text: value);
                                      } else {
                                        userModel.token = value;
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                '/mapselection');
                                      }
                                    },
                                  ).whenComplete(() =>
                                          controller.isLoading.value = false);
                                }
                              },
                            );
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        userModel.email = "gabriel@gmail.com";
                        userModel.password = "123456";
                        LoginRepository()
                            .postToken(
                          model: userModel,
                        )
                            .then(
                          (value) {
                            if (value.contains("Erro")) {
                              showMessageError(context: context, text: value);
                            } else {
                              userModel.token = value;
                              Navigator.of(context)
                                  .pushReplacementNamed('/mapselection');
                            }
                          },
                        ).whenComplete(
                                () => controller.isLoading.value = false);
                      },
                      child: const Text(
                        "Automático",
                        style: TextStyle(color: Colors.white),
                      )),
                  const Spacer(
                    flex: 4,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/recovery-password");
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Recuperar Senha",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
