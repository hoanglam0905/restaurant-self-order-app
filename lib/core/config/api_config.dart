class ApiConfig {
  const ApiConfig._();

  static const String backendRoot =
      'https://selforderingrestaurant-635x.onrender.com';

  // REST API
  static const String baseUrl = '$backendRoot/api';

  static const String backendOrigin = backendRoot;

  // GraphQL API
  static const String graphqlUrl = '$backendRoot/graphql';

  static Uri customerNotificationWebSocketUri(int tableNumber) {
    final backendUri = Uri.parse(backendRoot);
    final scheme = backendUri.scheme == 'https' ? 'wss' : 'ws';
    return backendUri.replace(
      scheme: scheme,
      path: '/ws/notifications',
      queryParameters: {
        'userType': 'CUSTOMER',
        'tableNumber': tableNumber.toString(),
      },
    );
  }
}
