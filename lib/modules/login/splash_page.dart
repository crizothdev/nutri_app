import 'package:flutter/material.dart';
import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

/// Tela de Splash com efeito de fade-in na imagem e navegação automática.
/// Objetivo: exibir uma imagem por alguns segundos com animação de opacidade
/// e, ao finalizar, redirecionar para a tela de login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// Controla a opacidade do AnimatedOpacity.
  /// Começa em 0.0 (invisível) e vai para 1.0 (visível) para criar o fade-in.
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    /// Aguarda 300ms antes de iniciar o fade-in.
    /// Motivo: dá tempo do primeiro frame renderizar, evitando
    /// que a animação “comece já no final” em alguns dispositivos.
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        /// Dispara a animação definindo a opacidade como 1.0.
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Scaffold fornece a estrutura visual básica da tela (fundo, body etc.).
      body: Center(
        /// Center centraliza o filho no meio da tela (horizontal e vertical).
        child: AnimatedOpacity(
          /// Valor atual da opacidade que será animada.
          opacity: _opacity,

          /// Duração do efeito de transição entre os valores de opacidade.
          /// Aqui: 2s para um fade-in suave.
          duration: const Duration(seconds: 2),

          /// onEnd é chamado quando a animação de opacidade termina.
          /// Usamos para aguardar mais 1s e então navegar para o login.
          onEnd: () {
            /// Pequena pausa após o fim da animação para manter a imagem visível.
            Future.delayed(const Duration(seconds: 1), () {
              /// Função de rota (definida em routes.dart) para ir à tela de login.
              /// Separar a navegação em função ajuda a manter o código organizado.
              goLogin();
            });
          },

          /// Curva da animação: easeIn começa mais lento e acelera no final,
          /// deixando o fade-in mais agradável.
          curve: Curves.easeIn,

          /// A imagem exibida no splash. Deve existir em pubspec.yaml (assets).
          /// Ex.:
          /// flutter:
          ///   assets:
          ///     - assets/images/splash_image.png
          child: Image.asset('assets/images/splash_image.png'),
        ),
      ),
    );
  }
}
