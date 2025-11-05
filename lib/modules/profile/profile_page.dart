

import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/profile/profile_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Tela de Perfil do Usuário
/// Segue o mesmo padrão visual das demais telas do app.
/// Mostra informações básicas como nome, e-mail, telefone e endereço.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller =
      AppBindings.I.get<ProfileController>(() => ProfileController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<ProfileController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Topo verde com botão de voltar e título
                Container(
                  color: const Color(0xFF9CAC7C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black87,
                      ),
                      const Text(
                        "Perfil",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Foto do usuário
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/user_photo.png'),
                ),
                const SizedBox(height: 12),

                // Endereço com ícone
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade800),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.mapPin, color: Colors.red),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          controller.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Campos de informação
                _buildInfoField("Nome", controller.name),
                _buildInfoField("E-mail", controller.email),
                _buildInfoField("Telefone", controller.phone),

                const Spacer(),

                // Bottom Navigation Bar
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A673D),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.bar_chart, color: Colors.white, size: 28),
                      Icon(Icons.home, color: Colors.white, size: 28),
                      Icon(Icons.settings, color: Colors.white, size: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget auxiliar para exibir os campos do perfil com bordas arredondadas
  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade800),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

