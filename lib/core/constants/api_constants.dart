class ApiConstants {
  ApiConstants._();

  static final String baseUrl = _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : 'https://medicare-server-9je0.onrender.com/v1';

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const Duration connectionTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ==================== AUTHENTICATION ROUTES ====================
  static String get register => '$baseUrl/users/register';
  static String get login => '$baseUrl/users/login';
  static String get verifyAuth => '$baseUrl/users/verify-auth';

  // ==================== LOCATION ROUTES ====================
  static String get divisions => '$baseUrl/locations/divisions';
  static String get districts => '$baseUrl/locations/districts';
  static String get upazilas => '$baseUrl/locations/upazilas';

  // ==================== USER PROFILE ROUTES ====================
  static String get profile => '$baseUrl/users/profile';
  static String get updateprofile => '$baseUrl/users/profile';
  static String get changePassword => '$baseUrl/users/change-password';

  // ==================== CART ROUTES ====================
  static String get cart => '$baseUrl/users/cart';
  static String get cartCount => '$baseUrl/users/cart/count';
  static String get addToCart => '$baseUrl/users/cart/add';
  static String cartItem(String itemId) => '$baseUrl/users/cart/item/$itemId';
  static String get clearCart => '$baseUrl/users/cart/clear';
  static String removeFromCart(String itemId) =>
      '$baseUrl/users/cart/item/$itemId';

  // ==================== PRODUCT ROUTES ====================
  static String get products => '$baseUrl/products';
  static String get productsOnSale => '$baseUrl/products/on-sale';
  static String get searchProducts => '$baseUrl/products/search';
  static String get trendingProducts => '$baseUrl/products/trending';
  static String get featuredProducts => '$baseUrl/products/featured';
  static String get newProducts => '$baseUrl/products/new';
  static String productDetail(String id) => '$baseUrl/products/$id';

  // ==================== CATEGORY ROUTES ====================
  static String get categories => '$baseUrl/categories';
  static String categoryDetail(String id) => '$baseUrl/categories/$id';
  static String categoryProducts(String id) =>
      '$baseUrl/categories/$id/products';

  // ==================== ORDER ROUTES ====================
  static String get createOrder => '$baseUrl/orders';
  static String get myOrders => '$baseUrl/orders/my-orders';
  static String myOrderDetail(String orderId) =>
      '$baseUrl/orders/my-orders/$orderId';
  static String cancelOrder(String orderId) =>
      '$baseUrl/orders/$orderId/cancel';

  // ==================== NOTIFICATIONS ROUTES ====================
  static String get notifications => '$baseUrl/notifications';
  static String get deviceNotificationToken =>
      '$baseUrl/notifications/device-token';
  static String notificationDetail(String id) => '$baseUrl/notifications/$id';
  static String get markAllNotificationsRead =>
      '$baseUrl/notifications/markall';
  static String get deleteAllNotifications =>
      '$baseUrl/notifications/alldelete';

  // ==================== HTTP METHODS ====================
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  // ==================== HEADERS ====================
  static Map<String, String> getHeaders({
    String? token,
    bool includeContentType = true,
  }) {
    return {
      'User-Agent': 'MediCare/1.0.0 (Flutter; Android/iOS)',
      if (includeContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) ...{
        'Authorization': 'Bearer $token',
        'customer-token': token,
      },
    };
  }
}
