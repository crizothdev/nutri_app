import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/login/login_controller.dart';
import 'package:nutri_app/modules/signup/signup_controller.dart';
import 'package:nutri_app/widgets/outlined_text_field.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final controller =
      AppBindings.I.get<SignupController>(() => SignupController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return NotifierScaffold<SignupController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              children: [
                SizedBox(height: 26),
                Image.asset(
                  'assets/images/splash_image.png',
                  scale: 4,
                ),
                Row(
                  children: const [
                    Text('Nome de usuário'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: 'meu apelido',
                  controller: state.usernameController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Senha'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: '*******',
                  controller: state.passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Nome completo'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: 'nome completo',
                  controller: state.nameController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('email'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: 'meu@email.com',
                  controller: state.emailController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Número de telefone'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: '12 99596 2256',
                  controller: state.phoneController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Documento de identificação'),
                  ],
                ),
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: '000.000.000.00',
                  controller: state.documentController,
                  obscureText: true,
                ),
                SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Registrar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
