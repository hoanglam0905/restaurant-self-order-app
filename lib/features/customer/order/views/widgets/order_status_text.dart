String orderStatusLabel(String status) {
  return switch (status.toUpperCase()) {
    'PENDING' => 'Đã nhận',
    'PROCESSING' => 'Đang chuẩn bị',
    'COMPLETED' => 'Đang giao',
    'CANCELLED' => 'Đã hủy',
    'SCHEDULED' => 'Đã đặt lịch',
    _ => status,
  };
}

String orderItemStatusLabel(String status) {
  return switch (status.toUpperCase()) {
    'PENDING' => 'Chờ bếp nhận',
    'PROCESSING' => 'Đang chuẩn bị',
    'COMPLETED' => 'Đã phục vụ',
    'CANCELLED' => 'Đã hủy',
    _ => status,
  };
}

String paymentStatusLabel(String status) {
  return switch (status.toUpperCase()) {
    'UNPAID' => 'Chưa thanh toán',
    'PAID' => 'Đã thanh toán',
    'PENDING' => 'Chờ thanh toán',
    'CANCELLED' => 'Đã hủy',
    _ => status,
  };
}
