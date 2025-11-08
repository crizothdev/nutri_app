import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';
import 'package:nutri_app/modules/profile/profile_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';
// import 'package:nutri_app/routes.dart'; // Removido, pois a edição será local

class ClientsDetail extends StatefulWidget {
  final Client client;
  const ClientsDetail({super.key, required this.client});

  @override
  State<ClientsDetail> createState() => _ClientsDetailState();
}

class _ClientsDetailState extends State<ClientsDetail> {
  late final controller;

  // NOVO: Variável de estado para controlar o modo de edição
  bool _isEditing = false;

  @override
  void initState() {
    controller = ProfileController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Client get client => widget.client;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4B6B36);

    return NotifierScaffold<ProfileController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    // BOTÃO DE EDITAR/SALVAR MODIFICADO
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            // Lógica de Salvar:
                            // 1. Coletar os dados dos campos (se forem usados controllers)
                            // 2. Enviar para o controller ou API
                            // 3. Opcional: Mostrar uma mensagem de sucesso

                            // Sai do modo de edição
                            _isEditing = false;
                          } else {
                            // Entra no modo de edição
                            _isEditing = true;
                          }
                        });
                      },
                      child: Text(
                        // Alterna entre 'Editar perfil' e 'Salvar'
                        _isEditing ? 'Salvar' : 'Editar perfil',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CAMPOS: Passando o _isEditing para controlar a edição
                    _buildLabel('Nome'),
                    _buildField(client.name, isEnabled: _isEditing),
                    _buildLabel('E-mail'),
                    _buildField(client.email ?? '', isEnabled: _isEditing),
                    _buildLabel('Telefone'),
                    _buildField(client.phone ?? '', isEnabled: _isEditing),
                    _buildLabel('Peso (Kg)'),
                    _buildField('${client.weight} Kg', isEnabled: _isEditing),
                    _buildLabel('Altura (m)'),
                    _buildField('${client.height} m', isEnabled: _isEditing),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                padding: const EdgeInsets.only(
                    top: 50, left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/avatar.jpg'),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.restaurant_outlined,
                            color: Colors.white, size: 28),
                        onPressed: () => goClientMenus(client),
                      ),
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.white, size: 28),
                        onPressed: () => goHome(),
                      ),
                      IconButton(
                          icon: Icon(Icons.chat_bubble_outline,
                              color: Colors.white, size: 28),
                          onPressed: null // () => goChat(client),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // FUNÇÃO MODIFICADA: Recebe o isEnabled para controlar a edição
  static Widget _buildField(String hint, {required bool isEnabled}) {
    return TextFormField(
      initialValue: hint,
      enabled: isEnabled, // <-- Desabilita/Habilita a edição
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            // Usa uma cor diferente se estiver desabilitado (opcional)
            color: isEnabled ? Colors.green : Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
