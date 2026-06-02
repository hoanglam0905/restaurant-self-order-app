import 'package:flutter/material.dart';

class ShiftRegistrationView extends StatefulWidget {
  const ShiftRegistrationView({super.key});

  @override
  State<ShiftRegistrationView> createState() => _ShiftRegistrationViewState();
}

class _ShiftRegistrationViewState extends State<ShiftRegistrationView> {
  _ShiftType _selectedType = _ShiftType.fullTime;
  final Set<String> _selectedShiftIds = <String>{};

  static const _fullTimeDays = <_ShiftDay>[
    _ShiftDay(
      label: 'Thứ 2',
      slots: [
        _ShiftSlot(
          id: 'ft-mon-1',
          name: 'Ca 01',
          timeRange: '07:00 - 12:00',
          hours: 5,
        ),
        _ShiftSlot(
          id: 'ft-mon-2',
          name: 'Ca 02',
          timeRange: '12:00 - 17:00',
          hours: 5,
        ),
      ],
    ),
    _ShiftDay(
      label: 'Thứ 3',
      slots: [
        _ShiftSlot(
          id: 'ft-tue-1',
          name: 'Ca 01',
          timeRange: '07:00 - 12:00',
          hours: 5,
        ),
      ],
    ),
    _ShiftDay(
      label: 'Thứ 4',
      slots: [
        _ShiftSlot(
          id: 'ft-wed-2',
          name: 'Ca 02',
          timeRange: '12:00 - 17:00',
          hours: 5,
        ),
      ],
    ),
    _ShiftDay(
      label: 'Thứ 5',
      slots: [
        _ShiftSlot(
          id: 'ft-thu-3',
          name: 'Ca 03',
          timeRange: '17:00 - 22:00',
          hours: 5,
        ),
      ],
    ),
  ];

  static const _partTimeDays = <_ShiftDay>[
    _ShiftDay(
      label: 'Thứ 2',
      slots: [
        _ShiftSlot(
          id: 'pt-mon-1',
          name: 'Ca sáng',
          timeRange: '08:00 - 11:30',
          hours: 3.5,
        ),
        _ShiftSlot(
          id: 'pt-mon-2',
          name: 'Ca chiều',
          timeRange: '13:00 - 16:30',
          hours: 3.5,
        ),
      ],
    ),
    _ShiftDay(
      label: 'Thứ 3',
      slots: [
        _ShiftSlot(
          id: 'pt-tue-1',
          name: 'Ca tối',
          timeRange: '18:00 - 21:30',
          hours: 3.5,
        ),
      ],
    ),
    _ShiftDay(
      label: 'Thứ 5',
      slots: [
        _ShiftSlot(
          id: 'pt-thu-1',
          name: 'Ca trưa',
          timeRange: '11:30 - 15:00',
          hours: 3.5,
        ),
      ],
    ),
  ];

  List<_ShiftDay> get _activeDays {
    return _selectedType == _ShiftType.fullTime ? _fullTimeDays : _partTimeDays;
  }

  int get _selectedCount => _selectedShiftIds.length;

  double get _selectedHours {
    var total = 0.0;
    for (final day in _activeDays) {
      for (final slot in day.slots) {
        if (_selectedShiftIds.contains(slot.id)) {
          total += slot.hours;
        }
      }
    }
    return total;
  }

  void _changeType(_ShiftType type) {
    if (_selectedType == type) {
      return;
    }

    setState(() {
      _selectedType = type;
      final activeIds = _activeDays
          .expand((day) => day.slots)
          .map((slot) => slot.id)
          .toSet();
      _selectedShiftIds.removeWhere((id) => !activeIds.contains(id));
    });
  }

  void _toggleShift(String shiftId) {
    setState(() {
      if (_selectedShiftIds.contains(shiftId)) {
        _selectedShiftIds.remove(shiftId);
      } else {
        _selectedShiftIds.add(shiftId);
      }
    });
  }

  void _submitRegistration() {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ca làm.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã tạo yêu cầu đăng ký $_selectedCount ca ($_formattedHours). Bạn có thể nối API tại đây.',
        ),
      ),
    );
  }

  String get _formattedHours {
    return _displayHours(_selectedHours);
  }

  String _displayHours(double hours) {
    if (hours % 1 == 0) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 180),
        children: [
          _buildTypeSwitch(),
          const SizedBox(height: 14),
          ..._activeDays.map(_buildDaySection),
        ],
      ),
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
                    onPressed: _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
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

  Widget _buildTypeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeItem(
              label: 'Full-time',
              selected: _selectedType == _ShiftType.fullTime,
              onTap: () => _changeType(_ShiftType.fullTime),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TypeItem(
              label: 'Part-time',
              selected: _selectedType == _ShiftType.partTime,
              onTap: () => _changeType(_ShiftType.partTime),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(_ShiftDay day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.label,
            style: const TextStyle(
              color: Color(0xFF7F8798),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...day.slots.map(_buildShiftCard),
        ],
      ),
    );
  }

  Widget _buildShiftCard(_ShiftSlot slot) {
    final isSelected = _selectedShiftIds.contains(slot.id);
    return InkWell(
      onTap: () => _toggleShift(slot.id),
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
                    slot.name,
                    style: const TextStyle(
                      color: Color(0xFF242B39),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.timeRange,
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
                _displayHours(slot.hours),
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
}

class _TypeItem extends StatelessWidget {
  const _TypeItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 36,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x150F172A),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF212939)
                    : const Color(0xFF737D90),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
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

class _ShiftDay {
  const _ShiftDay({required this.label, required this.slots});

  final String label;
  final List<_ShiftSlot> slots;
}

class _ShiftSlot {
  const _ShiftSlot({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.hours,
  });

  final String id;
  final String name;
  final String timeRange;
  final double hours;
}

enum _ShiftType { fullTime, partTime }
