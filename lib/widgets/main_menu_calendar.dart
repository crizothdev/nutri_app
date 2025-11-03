import 'package:flutter/material.dart';

/// Compara apenas ano/mês/dia
bool _sameYMD(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Retorna quantidade de dias do mês
int _daysInMonth(DateTime d) {
  final firstNext = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return firstNext.subtract(const Duration(days: 1)).day;
}

/// Calendário mensal minimalista (PT-BR)
class PtbCalendar extends StatefulWidget {
  /// Dias que devem receber a estrela (use somente Y/M/D)
  final Set<DateTime> markedDays;

  /// Dispara ao tocar em um dia
  final ValueChanged<DateTime>? onDayTap;

  /// Mês inicial (padrão: agora)
  final DateTime? initialMonth;

  const PtbCalendar({
    super.key,
    this.markedDays = const {},
    this.onDayTap,
    this.initialMonth,
  });

  @override
  State<PtbCalendar> createState() => _PtbCalendarState();
}

class _PtbCalendarState extends State<PtbCalendar> {
  late DateTime _visibleMonth; // sempre dia 1

  @override
  void initState() {
    super.initState();
    final now = widget.initialMonth ?? DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.month == 1 ? _visibleMonth.year - 1 : _visibleMonth.year,
        _visibleMonth.month == 1 ? 12 : _visibleMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.month == 12 ? _visibleMonth.year + 1 : _visibleMonth.year,
        _visibleMonth.month == 12 ? 1 : _visibleMonth.month + 1,
        1,
      );
    });
  }

  // Domingo como primeira coluna (Dom, Seg, Ter, Qua, Qui, Sex, Sáb)
  static const _weekdayLabels = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb'
  ];

  /// Offset da primeira célula considerando domingo=0
  int _firstWeekdayOffset(DateTime firstDay) {
    // DateTime.weekday: 1=Seg ... 7=Dom
    final wd = firstDay.weekday; // 1..7
    return wd % 7; // Dom(7)->0, Seg(1)->1, ..., Sáb(6)->6
  }

  String _monthName(int m) {
    const meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return meses[m];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final today = DateTime.now();

    final totalDays = _daysInMonth(_visibleMonth);
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leadingEmpty = _firstWeekdayOffset(firstDay);
    final cellsCount = leadingEmpty + totalDays;
    final rows = (cellsCount / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho: mês/ano + setas
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _prevMonth,
              tooltip: 'Mês anterior',
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
              tooltip: 'Próximo mês',
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Cabeçalho dos dias da semana (1ª coluna vermelha)
        Row(
          children: List.generate(7, (i) {
            final isSunday = i == 0;
            return Expanded(
              child: Center(
                child: Text(
                  _weekdayLabels[i],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSunday
                        ? Colors.red
                        : theme.textTheme.labelMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Grade
        Column(
          children: List.generate(rows, (r) {
            return Row(
              children: List.generate(7, (c) {
                final cellIndex = r * 7 + c;
                if (cellIndex < leadingEmpty ||
                    cellIndex >= leadingEmpty + totalDays) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                final day = cellIndex - leadingEmpty + 1;
                final cellDate =
                    DateTime(_visibleMonth.year, _visibleMonth.month, day);

                final isToday = _sameYMD(cellDate, today);
                final isMarked =
                    widget.markedDays.any((d) => _sameYMD(d, cellDate));
                final isSunday = c == 0;

                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => widget.onDayTap?.call(cellDate),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color: primary,
                                  width: 1.5) // círculo do dia atual
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: isSunday
                                    ? Colors.red
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (isMarked)
                              const Positioned(
                                right: 2,
                                top: 2,
                                child: Icon(Icons.star, size: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}
