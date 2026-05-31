class ApiConfig {
  const ApiConfig._();

  static const String backendRoot = 'https://selforderingrestaurant-635x.onrender.com';

  // REST API
  static const String baseUrl = '$backendRoot/api';
  static const String backendOrigin = '$backendRoot/api';

  // GraphQL API
  static const String graphqlUrl = '$backendRoot/graphql';
}