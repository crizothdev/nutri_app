import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/user.dart';

import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/main_menu_calendar.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class ScheduleModel {
  final int? id;
  final int? clientId; // opcional
  final String patientName; // obrigatório
  final String? phoneNumber; // opcional
  final DateTime date; // só a data
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String? title;
  final String? description;
  final String status; // 'scheduled'|'done'|'canceled'

  ScheduleModel({
    this.id,
    this.clientId,
    required this.patientName,
    this.phoneNumber,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.title,
    this.description,
    this.status = 'scheduled',
  });

  String get dateIso =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'patient_name': patientName,
        'phone_number': phoneNumber,
        'date_iso': dateIso,
        'start_time': startTime,
        'end_time': endTime,
        'title': title,
        'description': description,
        'status': status,
      };

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    final parts = (map['date_iso'] as String).split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);

    return ScheduleModel(
      id: map['id'] as int?,
      clientId: map['client_id'] as int?,
      patientName: map['patient_name'] as String,
      phoneNumber: map['phone_number'] as String?,
      date: DateTime(y, m, d),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      status: (map['status'] as String?) ?? 'scheduled',
    );
  }
}

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  @override
  void initState() {
    if (widget.user != null) {
      controller.setUser(widget.user!);
    }
    controller.fetchSchedulesAndPopulateMarkedDays();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  showNewScheduleModal(DateTime selectedDate) {
    goNewSchedule(selectedDate);
  }

  Future<void> openDayInfo(DateTime date) async {
    final schedules = controller.schedules
        .where((s) => DateUtils.isSameDay(s.date, date))
        .toList();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title:
              Text('Informações do dia ${date.day}/${date.month}/${date.year}'),
          content: Container(
            child: schedules.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('Nenhum agendamento para este dia.'),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: schedules.map((item) {
                      return Column(
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(item.patientName),
                            subtitle:
                                Text('${item.startTime} às ${item.endTime}'),
                          ),
                          Divider()
                        ],
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                showNewScheduleModal(date);
              },
              child: const Text('Adicionar Agendamento'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4B6B36);
    return NotifierScaffold<HomeController>(
      state: controller,
      isLoading: controller.isLoading,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          'Nutrify',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(Colors.white), // cor de fundo
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(100), // cantos arredondados
                ),
              ),
            ),
            onPressed: () {
              goProfile();
            },
            icon: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
      builder: (context, state) {
        return Stack(
          children: [
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white, size: 28),
                    Icon(Icons.home, color: Colors.white, size: 28),
                    Icon(Icons.chat_bubble_outline,
                        color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Center(
                child: Column(
                  children: [
                    PtbCalendar(
                      markedDays: controller.markedDays,
                      onDayTap: (date) {
                        openDayInfo(date);
                      },
                    ),
                    SizedBox(height: 40),
                    OutlinedButton(
                        onPressed: () {
                          goMyClients();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Clientes', style: TextStyle(fontSize: 18)),
                          ],
                        )),
                    SizedBox(height: 12),
                    OutlinedButton(
                        onPressed: () {
                          goSchedules();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Agendamentos',
                                style: TextStyle(fontSize: 18)),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
