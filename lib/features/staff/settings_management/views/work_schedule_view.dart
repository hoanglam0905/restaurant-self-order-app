import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../data/services/settings_service.dart';

class WorkScheduleView extends StatefulWidget {
  const WorkScheduleView({super.key});

  @override
  State<WorkScheduleView> createState() => _WorkScheduleViewState();
}

class _WorkScheduleViewState extends State<WorkScheduleView> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SettingsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMySchedule();
    });
  }

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
            onPressed: _controller.loadMySchedule,
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF798296)),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isScheduleLoading.value &&
            _controller.scheduleDays.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB84D2D)),
          );
        }

        if (_controller.scheduleErrorMessage.value.isNotEmpty &&
            _controller.scheduleDays.isEmpty) {
          return _ErrorPanel(
            message: _controller.scheduleErrorMessage.value,
            onRetry: _controller.loadMySchedule,
          );
        }

        final days = _controller.scheduleDays.toList();

        return RefreshIndicator(
          color: const Color(0xFFB84D2D),
          onRefresh: _controller.loadMySchedule,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              _WeeklySummaryCard(days: days),
              const SizedBox(height: 14),
              ...days.map(_buildDayCard),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDayCard(StaffScheduleDayModel day) {
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
                day.weekdayLabel,
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

  Widget _buildShiftTile(StaffShiftScheduleModel shift) {
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
                  shift.shiftName,
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
          if (shift.staffShiftId != null && shift.status == 'ASSIGNED')
            IconButton(
              tooltip: 'Hủy ca',
              onPressed: () => _confirmCancelShift(shift.staffShiftId!),
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFFD24B35),
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

  Future<void> _confirmCancelShift(int staffShiftId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy ca làm'),
        content: const Text('Bạn có chắc muốn hủy ca làm này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hủy ca'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _controller.cancelShift(staffShiftId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy ca làm.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SettingsService.errorMessage(error))),
      );
    }
  }

  _ShiftStatusStyle _statusStyle(String? status) {
    switch (status) {
      case 'COMPLETED':
        return const _ShiftStatusStyle(
          label: 'Đã hoàn thành',
          textColor: Color(0xFF0F8B54),
          backgroundColor: Color(0xFFF1FCF6),
          tagBackgroundColor: Color(0xFFD9F4E5),
          borderColor: Color(0xFFDCF1E5),
        );
      case 'ABSENT':
        return const _ShiftStatusStyle(
          label: 'Vắng mặt',
          textColor: Color(0xFFC62828),
          backgroundColor: Color(0xFFFFF5F5),
          tagBackgroundColor: Color(0xFFFFE0E0),
          borderColor: Color(0xFFFFD3D3),
        );
      default:
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

  final List<StaffScheduleDayModel> days;

  @override
  Widget build(BuildContext context) {
    var totalShifts = 0;
    var completedShifts = 0;
    var totalHours = 0.0;

    for (final day in days) {
      totalShifts += day.shifts.length;
      completedShifts += day.shifts.where((shift) => shift.status == 'COMPLETED').length;

      for (final shift in day.shifts) {
        totalHours += shift.endDateTime.difference(shift.startDateTime).inMinutes / 60;
      }
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
            child: _SummaryMetric(label: 'Tổng ca tuần', value: '$totalShifts ca'),
          ),
          Expanded(
            child: _SummaryMetric(label: 'Đã xong', value: '$completedShifts ca'),
          ),
          Expanded(
            child: _SummaryMetric(label: 'Tổng giờ', value: _formatHours(totalHours)),
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours % 1 == 0) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
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

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF555D6D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}