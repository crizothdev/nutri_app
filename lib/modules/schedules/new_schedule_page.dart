import 'package:flutter/material.dart';
import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/modules/home/home_page.dart';

class NewSchedulePage extends StatefulWidget {
  DateTime selectedDate;
  NewSchedulePage({required this.selectedDate, super.key});

  @override
  State<NewSchedulePage> createState() => _NewSchedulePageState();
}

class _NewSchedulePageState extends State<NewSchedulePage> {
  final controller = HomeController();
  late DateTime _selectedDate;
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  fullfillFormDialog() {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Por favor, preencha todos os campos obrigatórios.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(c).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  final nameController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final phoneController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Agendamento'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(fontSize: 22),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome do Paciente'),
            ),
            TextField(
              controller: startTimeController,
              readOnly: true,
              onTap: () async {
                final startTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (startTime != null) {
                  startTimeController.text = startTime.format(context);
                }
              },
              decoration: InputDecoration(labelText: 'Horário de Início'),
            ),
            TextField(
              controller: endTimeController,
              readOnly: true,
              onTap: () async {
                final endTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (endTime != null) {
                  endTimeController.text = endTime.format(context);
                }
              },
              decoration: InputDecoration(labelText: 'Horário de Fim'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observações',
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty) {
                  // Exibir mensagem de erro ou alerta
                  fullfillFormDialog();
                } else {
                  // Lógica para criar novo agendamento
                  controller.newSchedule(ScheduleModel(
                    id: null,
                    clientId: null,
                    patientName: nameController.text,
                    phoneNumber: phoneController.text,
                    date: _selectedDate,
                    startTime: startTimeController.text,
                    endTime: endTimeController.text,
                    title: titleController.text,
                    description: descriptionController.text,
                  ));

                  Navigator.of(context).pop();
                }
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
