import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../data/services/settings_service.dart';

class ShiftRegistrationView extends StatefulWidget {
  const ShiftRegistrationView({super.key});

  @override
  State<ShiftRegistrationView> createState() => _ShiftRegistrationViewState();
}

class _ShiftRegistrationViewState extends State<ShiftRegistrationView> {
  late final SettingsController _controller;

  final Set<String> _selectedShiftKeys = <String>{};
  bool _isSubmitting = false;

  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SettingsController>();
    _weekStart = _startOfWeek(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadAvailableShiftsForWeek(_weekStart);
    });
  }

  int get _selectedCount => _selectedShiftKeys.length;

  double get _selectedHours {
    var total = 0.0;

    for (final day in _controller.availableShiftDays) {
      for (final shift in day.shifts) {
        if (_selectedShiftKeys.contains(_shiftKey(day.date, shift.shiftId))) {
          total += shift.endDateTime.difference(shift.startDateTime).inMinutes / 60;
        }
      }
    }

    return total;
  }

  String get _formattedHours {
    if (_selectedHours % 1 == 0) {
      return '${_selectedHours.toInt()}h';
    }

    return '${_selectedHours.toStringAsFixed(1)}h';
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - DateTime.monday));
  }

  String _shiftKey(DateTime date, int shiftId) {
    return '${_apiDate(date)}|$shiftId';
  }

  void _toggleShift(DateTime date, int shiftId) {
    final key = _shiftKey(date, shiftId);

    setState(() {
      if (_selectedShiftKeys.contains(key)) {
        _selectedShiftKeys.remove(key);
      } else {
        _selectedShiftKeys.add(key);
      }
    });
  }

  Future<void> _goToPreviousWeek() async {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedShiftKeys.clear();
    });

    await _controller.loadAvailableShiftsForWeek(_weekStart);
  }

  Future<void> _goToNextWeek() async {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedShiftKeys.clear();
    });

    await _controller.loadAvailableShiftsForWeek(_weekStart);
  }

  Future<void> _submitRegistration() async {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ca làm.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    var successCount = 0;

    try {
      final selectedItems = <_SelectedShiftItem>[];

      for (final day in _controller.availableShiftDays) {
        for (final shift in day.shifts) {
          final key = _shiftKey(day.date, shift.shiftId);
          if (_selectedShiftKeys.contains(key)) {
            selectedItems.add(
              _SelectedShiftItem(
                date: day.date,
                shiftId: shift.shiftId,
                shiftName: shift.shiftName,
              ),
            );
          }
        }
      }

      for (final item in selectedItems) {
        await _controller.registerShift(
          shiftId: item.shiftId,
          date: item.date,
        );
        successCount++;
      }

      if (!mounted) return;

      setState(() {
        _selectedShiftKeys.clear();
      });

      await _controller.loadAvailableShiftsForWeek(_weekStart);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký thành công $successCount ca làm.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SettingsService.errorMessage(error)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF202736)),
        title: const Text(
          'Đăng ký lịch làm',
          style: TextStyle(
            color: Color(0xFF202736),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.loadAvailableShiftsForWeek(_weekStart),
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF798296)),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isAvailableShiftLoading.value &&
            _controller.availableShiftDays.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB84D2D)),
          );
        }

        if (_controller.availableShiftErrorMessage.value.isNotEmpty &&
            _controller.availableShiftDays.isEmpty) {
          return _ErrorPanel(
            message: _controller.availableShiftErrorMessage.value,
            onRetry: () => _controller.loadAvailableShiftsForWeek(_weekStart),
          );
        }

        final days = _controller.availableShiftDays.toList();

        return RefreshIndicator(
          color: const Color(0xFFB84D2D),
          onRefresh: () => _controller.loadAvailableShiftsForWeek(_weekStart),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 180),
            children: [
              _buildWeekNavigator(),
              const SizedBox(height: 14),
              if (days.isEmpty)
                const _EmptyPanel()
              else
                ...days.map(_buildDaySection),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7EAF2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14111827),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryValue(
                      label: 'Tổng ca đã chọn',
                      value: '$_selectedCount ca làm',
                      valueColor: const Color(0xFFB84D2D),
                    ),
                  ),
                  _SummaryValue(
                    label: 'Thời gian',
                    value: _formattedHours,
                    valueColor: const Color(0xFF2F3645),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFC96541), Color(0xFFB84D2D)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB84D2D).withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Đăng ký lịch làm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigator() {
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _goToPreviousWeek,
            icon: const Icon(Icons.chevron_left_rounded),
            color: const Color(0xFFB84D2D),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Tuần đăng ký',
                  style: TextStyle(
                    color: Color(0xFF96A0B1),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_displayDate(_weekStart)} - ${_displayDate(weekEnd)}',
                  style: const TextStyle(
                    color: Color(0xFF242B39),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _goToNextWeek,
            icon: const Icon(Icons.chevron_right_rounded),
            color: const Color(0xFFB84D2D),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(StaffScheduleDayModel day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                day.weekdayLabel,
                style: const TextStyle(
                  color: Color(0xFF7F8798),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day.dateLabel,
                style: const TextStyle(
                  color: Color(0xFF9AA3B3),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (day.shifts.isEmpty)
            const _NoShiftPlaceholder()
          else
            ...day.shifts.map((shift) => _buildShiftCard(day, shift)),
        ],
      ),
    );
  }

  Widget _buildShiftCard(
    StaffScheduleDayModel day,
    StaffShiftScheduleModel shift,
  ) {
    final key = _shiftKey(day.date, shift.shiftId);
    final isSelected = _selectedShiftKeys.contains(key);
    final hours = shift.endDateTime.difference(shift.startDateTime).inMinutes / 60;

    return InkWell(
      onTap: () => _toggleShift(day.date, shift.shiftId),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3EE) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB84D2D)
                : const Color(0xFFE7EAF2),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB84D2D).withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFB84D2D)
                    : const Color(0xFFF1F3F8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB84D2D)
                      : const Color(0xFFD9DFEB),
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: isSelected ? Colors.white : Colors.transparent,
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
                      color: Color(0xFF242B39),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shift.timeRange,
                    style: const TextStyle(
                      color: Color(0xFF717A8D),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFE5DA)
                    : const Color(0xFFF3F5FA),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _displayHours(hours),
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFB84D2D)
                      : const Color(0xFF7B8395),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayHours(double hours) {
    if (hours % 1 == 0) {
      return '${hours.toInt()}h';
    }

    return '${hours.toStringAsFixed(1)}h';
  }

  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _SelectedShiftItem {
  const _SelectedShiftItem({
    required this.date,
    required this.shiftId,
    required this.shiftName,
  });

  final DateTime date;
  final int shiftId;
  final String shiftName;
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF96A0B1),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
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
        'Không còn ca trống trong ngày này.',
        style: TextStyle(
          color: Color(0xFF818B9E),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: const Text(
        'Không có dữ liệu ca làm để đăng ký.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF697285),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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

String _apiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}