import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/models/client.dart';

class MyClientsController extends ChangeNotifier {
  final clientsRepo = AppInitializer.clientsRepository;

  List<Client> clientes = <Client>[];

  bool isLoading = false;
  toggleLoading([bool? val]) {
    isLoading = val ?? !isLoading;
    notifyListeners();
  }

  createClient(Client client) async {
    toggleLoading(true);
    try {
      final newClientId = await clientsRepo.create(
          userId: AppInitializer.appInfo.currentUser!.id!, client: client);

      print('newClientId $newClientId');
    } catch (e) {
      print('Error creating client: $e');
    }
    toggleLoading(false);
  }

  fetchClients() async {
    toggleLoading(true);
    try {
      clientsRepo
          .list(userId: AppInitializer.appInfo.currentUser!.id!)
          .then((value) {
        clientes = value;
        toggleLoading(false);
      });
    } catch (e) {
      print('Error fetching clients: $e');
    } finally {
      toggleLoading(false);
    }
  }
}
