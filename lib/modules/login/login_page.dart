import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/login/login_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/outlined_text_field.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

/// Tela de Login do app.
/// Esta tela permite que o usuário insira suas credenciais para acessar o sistema.
/// Possui campos para login, senha, botões de recuperação de senha e registro.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Controller responsável pela lógica do login.
  /// Obtido através do AppBindings para injeção de dependências.
  final controller =
      AppBindings.I.get<LoginController>(() => LoginController());

  @override
  void dispose() {
    /// Garante que os recursos do controller sejam liberados corretamente
    /// quando a tela for destruída, evitando vazamentos de memória.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return NotifierScaffold<LoginController>(
      /// Vincula o estado ao NotifierScaffold para atualização automática da UI
      state: controller,

      /// Mostra um CircularProgressIndicator quando `isLoading` for true,
      /// útil para quando o login estiver sendo processado.
      isLoading: controller.isLoading,

      /// Builder que constrói o layout principal da tela.
      builder: (context, state) {
        return Center(
          /// Padding para adicionar espaçamento horizontal,
          /// evitando que os elementos fiquem grudados nas bordas da tela.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),

            /// Coluna principal que organiza todos os elementos verticalmente.
            child: Column(
              children: [
                /// Espaço no topo proporcional ao tamanho da tela,
                /// ajusta a posição dos elementos independentemente do dispositivo.
                SizedBox(height: MediaQuery.of(context).size.height / 8),

                /// Logo do aplicativo, vindo dos assets.
                /// `scale: 2` reduz o tamanho proporcional da imagem.
                Image.asset(
                  'assets/images/splash_image.png',
                  scale: 2,
                ),

                /// Label para o campo de login.
                /// aqui eu uso um row para que o Text venha obrigatoriamente para o inicio da linha
                Row(
                  children: const [
                    Text('Login*'),
                  ],
                ),

                /// Campo de texto para o login com borda arredondada.
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: 'Texto aqui...',
                  controller: usernameController,
                ),

                const SizedBox(height: 10),

                /// Label para o campo de senha.
                /// aqui eu uso um row para que o Text venha obrigatoriamente para o inicio da linha
                Row(
                  children: const [
                    Text('Senha*'),
                  ],
                ),

                /// Campo de texto para senha.
                /// (Neste caso ainda não está configurado como campo de senha real,
                /// o ideal seria adicionar obscureText: true para ocultar os caracteres).
                OutlinedTextField(
                  hintText: 'Digite algo',
                  labelText: 'Texto aqui...',
                  controller: passwordController,
                  obscureText: true,
                ),

                /// Botão para recuperação de login/senha,
                /// posicionado à direita usando `mainAxisAlignment.end`.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        /// Ação para recuperação de senha ou login esquecido.
                      },
                      child: const Text('Esqueceu login ou senha?'),
                    ),
                  ],
                ),

                /// Botão principal para efetuar login.
                /// Usa FilledButton para estilo preenchido.
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: FilledButton(
                          onPressed: () {
                            /// Aqui será implementada a lógica de autenticação.
                            goClientsDetail();
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Entrar'),
                        ),
                      ),
                    ),
                  ],
                ),

                /// Botão para redirecionar à tela de registro.
                TextButton(
                  onPressed: () {
                    goSignup();
                  },
                  child: const Text('Registre-se'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
