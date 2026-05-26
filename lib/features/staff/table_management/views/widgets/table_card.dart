import 'package:flutter/material.dart';
import '../../data/models/staff_table_model.dart';
import '../../data/models/table_status.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.table,
    this.onTap,
    this.onMoreTap,
  });

  final StaffTableModel table;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.status == TableStatus.occupied;
    final isReserved = table.status == TableStatus.reserved;
    final isActive = isOccupied || isReserved;
    
    // Aesthetic Color tokens matching the mockup
    const occupiedBorderColor = Color(0xFF9E3A14);
    const occupiedTextColor = Color(0xFF9E3A14);
    // A73413 with 5% opacity for occupied background
    const occupiedBgColor = Color(0x0DA73413); // 0x0D = ~5% of 255
    const reservedBorderColor = Color(0xFFE6A817);
    const reservedTextColor = Color(0xFFB8860B);
    const reservedBgColor = Color(0x0DE6A817); // 5% opacity amber
    const emptyBgColor = Color(0xFFF4F6FA);
    const emptyTextColor = Color(0xFF8A9AAB);
    const emptyIconColor = Color(0xFFD0DCE7);

    // Pick colors based on state
    final borderColor = isOccupied
        ? occupiedBorderColor
        : isReserved
            ? reservedBorderColor
            : Colors.transparent;
    final bgColor = isOccupied
        ? occupiedBgColor
        : isReserved
            ? reservedBgColor
            : emptyBgColor;
    final accentTextColor = isOccupied
        ? occupiedTextColor
        : isReserved
            ? reservedTextColor
            : emptyTextColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card body
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Table Name & Capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        table.tableNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isActive ? Colors.black87 : emptyTextColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: isActive ? Colors.black54 : emptyTextColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            table.capacity.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.black87 : emptyTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Middle Content: Status & Progress
                  if (isOccupied) ...[
                    const Text(
                      'BÀN CÓ KHÁCH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: occupiedTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (table.orderProgressText != null)
                      Text(
                        table.orderProgressText!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    const Spacer(),
                    
                    // Bottom Row: Time and Action menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          table.activeTimeText ?? '0m active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: onMoreTap,
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: occupiedTextColor,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ] else if (isReserved) ...[
                    Text(
                      'ĐÃ ĐẶT TRƯỚC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: accentTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Chờ khách đến',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Icon(
                          Icons.event_seat_rounded,
                          size: 36,
                          color: Color(0xFFE6A817),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'BÀN TRỐNG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: emptyTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Icon(
                          Icons.chair_alt_outlined,
                          size: 36,
                          color: emptyIconColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Overlapping red Alert Badge on occupied tables with notifications
        if (isOccupied && table.hasAlert)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFC62828), // Deep Alert Red
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),

        // Amber clock icon for reserved tables
        if (isReserved)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE6A817),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }
}
