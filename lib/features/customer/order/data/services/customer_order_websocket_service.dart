import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../../core/config/api_config.dart';
import '../models/customer_order_websocket_event.dart';

class CustomerOrderWebSocketService {
  CustomerOrderWebSocketService();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _pingTimer;
  int? _tableNumber;
  bool _closedByClient = false;

  final StreamController<CustomerOrderWebSocketEvent> _events =
      StreamController<CustomerOrderWebSocketEvent>.broadcast();

  Stream<CustomerOrderWebSocketEvent> get events => _events.stream;

  Future<void> connect(int tableNumber) async {
    if (_tableNumber == tableNumber && _socket?.readyState == WebSocket.open) {
      return;
    }

    await disconnect();
    _tableNumber = tableNumber;
    _closedByClient = false;

    try {
      final uri = ApiConfig.customerNotificationWebSocketUri(tableNumber);
      final socket = await WebSocket.connect(uri.toString());
      _socket = socket;
      _socketSubscription = socket.listen(
        _handleMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_socket?.readyState == WebSocket.open) {
          _socket?.add('{"type":"PING"}');
        }
      });
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _closedByClient = true;
    _pingTimer?.cancel();
    _pingTimer = null;
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.close();
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _events.close();
  }

  void _handleMessage(dynamic payload) {
    if (payload is! String || payload == 'PONG') {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final event = CustomerOrderWebSocketEvent.fromJson(decoded);
        if (event.isOrderUpdate && !_events.isClosed) {
          _events.add(event);
        }
      }
    } catch (_) {
      // Ignore non-JSON messages from the raw WebSocket endpoint.
    }
  }

  void _scheduleReconnect() {
    final tableNumber = _tableNumber;
    if (_closedByClient || tableNumber == null || _events.isClosed) {
      return;
    }

    _pingTimer?.cancel();
    _pingTimer = null;
    unawaited(_socketSubscription?.cancel());
    _socketSubscription = null;
    _socket = null;

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!_closedByClient && !_events.isClosed) {
        connect(tableNumber);
      }
    });
  }
}
