class ApiConstants {
  ApiConstants._();

  // ✅ Single Railway URL for all platforms since it's deployed
  static const String baseUrl = 'https://medicare-server-black.vercel.app/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== AUTHENTICATION ROUTES ====================
  static String get register => '$baseUrl/users/register';
  static String get login => '$baseUrl/users/login';
  static String get verifyAuth => '$baseUrl/users/verify-auth';

  // ==================== USER PROFILE ROUTES ====================
  static String get profile => '$baseUrl/users/profile';
  static String get changePassword => '$baseUrl/users/change-password';

  // ==================== ADDRESS ROUTES ====================
  static String get addresses => '$baseUrl/users/addresses';
  static String addressDefault(String addressId) =>
      '$baseUrl/users/addresses/$addressId/default';
  static String addressDetail(String addressId) =>
      '$baseUrl/users/addresses/$addressId';

  // ==================== CART ROUTES ====================
  static String get cart => '$baseUrl/users/cart';
  static String get cartCount => '$baseUrl/users/cart/count';
  static String get addToCart => '$baseUrl/users/cart/add';
  static String cartItem(String itemId) =>
      '$baseUrl/users/cart/item/$itemId';
  static String get clearCart => '$baseUrl/users/cart/clear';
  static String removeFromCart(String itemId) =>
      '$baseUrl/users/cart/item/$itemId';

  // ==================== NOTIFICATION ROUTES ====================
  static String get notifications => '$baseUrl/users/notifications';
  static String get markAllRead => '$baseUrl/users/notifications/read-all';
  static String markNotificationRead(String notificationId) =>
      '$baseUrl/users/notifications/$notificationId/read';

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

  // ==================== HTTP METHODS ====================
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  // ==================== HEADERS ====================
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
