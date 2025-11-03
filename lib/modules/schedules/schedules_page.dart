import 'package:flutter/material.dart';
import 'package:nutri_app/modules/home/home_page.dart';
import 'package:nutri_app/modules/schedules/schedules_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final controller = SchedulesController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller.getAllSchedules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<SchedulesController>(
      state: controller,
      isLoading: controller.isLoading,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          'Meus Agendamentos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () {
          // createNewClient();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ListView.builder(
              itemCount: controller.schedules.length,
              itemBuilder: (context, index) {
                final item = controller.schedules[index];
                return ScheduleCard(item: item);
              },
            ),
          ),
        );
      },
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final ScheduleModel item;
  const ScheduleCard({super.key, required this.item});

  formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.patientName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Data: ${formatDate(item.dateIso)}'),
            Text('Telefone: ${item.phoneNumber}'),
          ],
        ),
      ),
    );
  }
}
