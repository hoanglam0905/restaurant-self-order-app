import 'package:flutter/material.dart';

class WorkScheduleView extends StatelessWidget {
  const WorkScheduleView({super.key});

  static const _days = <_WorkDaySchedule>[
    _WorkDaySchedule(
      weekday: 'Thứ 2',
      dateLabel: '01/06',
      isToday: true,
      shifts: [
        _WorkShift(
          name: 'Ca 01',
          timeRange: '07:00 - 12:00',
          status: _WorkShiftStatus.completed,
        ),
        _WorkShift(
          name: 'Ca 02',
          timeRange: '12:00 - 17:00',
          status: _WorkShiftStatus.upcoming,
        ),
      ],
    ),
    _WorkDaySchedule(
      weekday: 'Thứ 3',
      dateLabel: '02/06',
      shifts: [
        _WorkShift(
          name: 'Ca 01',
          timeRange: '07:00 - 12:00',
          status: _WorkShiftStatus.upcoming,
        ),
      ],
    ),
    _WorkDaySchedule(
      weekday: 'Thứ 4',
      dateLabel: '03/06',
      shifts: [
        _WorkShift(
          name: 'Ca 02',
          timeRange: '12:00 - 17:00',
          status: _WorkShiftStatus.upcoming,
        ),
      ],
    ),
    _WorkDaySchedule(weekday: 'Thứ 5', dateLabel: '04/06', shifts: []),
    _WorkDaySchedule(
      weekday: 'Thứ 6',
      dateLabel: '05/06',
      shifts: [
        _WorkShift(
          name: 'Ca 03',
          timeRange: '17:00 - 22:00',
          status: _WorkShiftStatus.upcoming,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1F2533)),
        title: const Text(
          'Lịch làm việc',
          style: TextStyle(
            color: Color(0xFF1F2533),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn có thể gọi API tải lại lịch tại đây.'),
                ),
              );
            },
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF798296)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _WeeklySummaryCard(days: _days),
          const SizedBox(height: 14),
          ..._days.map(_buildDayCard),
        ],
      ),
    );
  }

  Widget _buildDayCard(_WorkDaySchedule day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                day.weekday,
                style: const TextStyle(
                  color: Color(0xFF202736),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day.dateLabel,
                style: const TextStyle(
                  color: Color(0xFF8A92A2),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (day.isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Hôm nay',
                    style: TextStyle(
                      color: Color(0xFFB84D2D),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (day.shifts.isEmpty)
            const _NoShiftPlaceholder()
          else
            ...day.shifts.map(_buildShiftTile),
        ],
      ),
    );
  }

  Widget _buildShiftTile(_WorkShift shift) {
    final colors = _statusStyle(shift.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Color(0xFF6E7788),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.name,
                  style: const TextStyle(
                    color: Color(0xFF252D3D),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shift.timeRange,
                  style: const TextStyle(
                    color: Color(0xFF697285),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.tagBackgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              colors.label,
              style: TextStyle(
                color: colors.textColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ShiftStatusStyle _statusStyle(_WorkShiftStatus status) {
    switch (status) {
      case _WorkShiftStatus.completed:
        return const _ShiftStatusStyle(
          label: 'Đã hoàn thành',
          textColor: Color(0xFF0F8B54),
          backgroundColor: Color(0xFFF1FCF6),
          tagBackgroundColor: Color(0xFFD9F4E5),
          borderColor: Color(0xFFDCF1E5),
        );
      case _WorkShiftStatus.upcoming:
        return const _ShiftStatusStyle(
          label: 'Sắp tới',
          textColor: Color(0xFFB84D2D),
          backgroundColor: Color(0xFFFFF8F4),
          tagBackgroundColor: Color(0xFFFFEBDD),
          borderColor: Color(0xFFF6E5DB),
        );
    }
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.days});

  final List<_WorkDaySchedule> days;

  @override
  Widget build(BuildContext context) {
    var totalShifts = 0;
    var completedShifts = 0;
    for (final day in days) {
      totalShifts += day.shifts.length;
      completedShifts += day.shifts
          .where((shift) => shift.status == _WorkShiftStatus.completed)
          .length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB84D2D), Color(0xFFD17652)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3CB84D2D),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: 'Tổng ca tuần',
              value: '$totalShifts ca',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: 'Đã xong',
              value: '$completedShifts ca',
            ),
          ),
          const Expanded(
            child: _SummaryMetric(label: 'Tổng giờ', value: '20h'),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF8D8CC),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _NoShiftPlaceholder extends StatelessWidget {
  const _NoShiftPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EBF3)),
      ),
      child: const Text(
        'Không có ca làm trong ngày này.',
        style: TextStyle(
          color: Color(0xFF818B9E),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WorkDaySchedule {
  const _WorkDaySchedule({
    required this.weekday,
    required this.dateLabel,
    required this.shifts,
    this.isToday = false,
  });

  final String weekday;
  final String dateLabel;
  final bool isToday;
  final List<_WorkShift> shifts;
}

class _WorkShift {
  const _WorkShift({
    required this.name,
    required this.timeRange,
    required this.status,
  });

  final String name;
  final String timeRange;
  final _WorkShiftStatus status;
}

enum _WorkShiftStatus { completed, upcoming }

class _ShiftStatusStyle {
  const _ShiftStatusStyle({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.tagBackgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color tagBackgroundColor;
  final Color borderColor;
}
