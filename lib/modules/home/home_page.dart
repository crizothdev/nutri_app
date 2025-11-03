import 'package:flutter/material.dart';
import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/main_menu_calendar.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class ScheduleModel {
  String patientName;
  String startTime;
  String endTime;
  String phoneNumber;
  DateTime date;

  ScheduleModel({
    required this.patientName,
    required this.startTime,
    required this.endTime,
    required this.phoneNumber,
    required this.date,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  showNewScheduleModal(DateTime selectedDate) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final nameController = TextEditingController();
          final startTimeController = TextEditingController();
          final endTimeController = TextEditingController();
          final phoneController = TextEditingController();

          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Novo Agendamento', style: TextStyle(fontSize: 24)),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nome do Paciente'),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: InputDecoration(labelText: 'Horário de Início'),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: InputDecoration(labelText: 'Horário de Fim'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Telefone'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para criar novo agendamento
                  },
                  child: Text('Salvar'),
                ),
              ],
            ),
          );
        });
  }

  openDayInfo(DateTime date) {
    //TODO
    bool hasInfoOnControllerInThisDate = false;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Informações do dia ${date.day}/${date.month}/${date.year}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasInfoOnControllerInThisDate)
                  Text('Nenhum agendamento para este dia.'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showNewScheduleModal(date);
                  },
                  child: Text('Adicionar Agendamento'),
                ),
              ],
            ),
          );
        });
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
            onPressed: () {},
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
                          goMyClients();
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
