class ApiConfig {
  static const String baseUrl = 'https://rapidapi.bsite.net';

  // Google Auth
  static const String googleRegister = '/api/GoogleAuth/RegisterAsync';
  static const String googleAcceptTerms = '/api/GoogleAuth/AcceptTermsAsync';
  static const String googleLogin = '/api/GoogleAuth/LoginAsync';

  // Registration
  static const String createEmailAccount = '/api/Registration/CreateEmailAccountAsync';
  static const String completeOnboarding = '/api/Registration/CompleteOnboardingAsync';

  // App Auth
  static const String requestOtp = '/api/AppAuth/RequestOtpAsync';
  static const String verifyOtp = '/api/AppAuth/VerifyOtpAsync';
  static const String appAuthLogin = '/api/AppAuth/LoginAsync';
  static const String generateAccessToken = '/api/AppAuth/GenerateAccessTokenAsync';
  static const String appAuthLogout = '/api/AppAuth/LogoutAsync';

  static const String login = '/api/v1/vendor/auth/login';
  static const String logout = '/api/v1/vendor/auth/logout';
  static const String dashboard = '/api/v1/vendor/dashboard';
  static const String status = '/api/v1/vendor/status';

  // Notifications
  static const String notifications = '/api/v1/vendor/notifications';
  static const String markNotificationsRead = '/api/v1/vendor/notifications/mark-all-read';
  static const String clearNotifications = '/api/v1/vendor/notifications/clear';

  // Analytics
  static const String analytics = '/api/v1/vendor/analytics';

  // Tracking
  static const String tracking = '/api/v1/vendor/tracking';
  static const String trackingPickers = '/api/v1/vendor/tracking/pickers';

  // Staff
  static const String staff = '/api/v1/vendor/staff';

  // Order History
  static const String history = '/api/v1/vendor/history';
  // Orders
  static const String orders = '/api/v1/vendor/orders';
  static String orderDetails(String uuid) => '/api/v1/vendor/orders/$uuid';
  static String acceptOrder(String uuid) => '/api/v1/vendor/orders/$uuid/accept';
  static String rejectOrder(String uuid) => '/api/v1/vendor/orders/$uuid/reject';
  static String assignPicker(String uuid) => '/api/v1/vendor/orders/$uuid/assign-picker';
  static String selfAssignOrder(String uuid) => '/api/v1/vendor/orders/$uuid/self-assign';
  static String startPicking(String uuid) => '/api/v1/vendor/orders/$uuid/start-picking';
  static String pickItem(String orderUuid, String itemUuid) => '/api/v1/vendor/orders/$orderUuid/items/$itemUuid/pick';
  static String rejectItem(String orderUuid, String itemUuid) => '/api/v1/vendor/orders/$orderUuid/items/$itemUuid/reject';
  static String completePicking(String uuid) => '/api/v1/vendor/orders/$uuid/complete-picking';
  static String rejectWholeOrder(String uuid) => '/api/v1/vendor/orders/$uuid/reject-order';
  static String startPacking(String uuid) => '/api/v1/vendor/orders/$uuid/start-packing';
  static String completePacking(String uuid) => '/api/v1/vendor/orders/$uuid/complete-packing';
  static String readyForDispatch(String uuid) => '/api/v1/vendor/orders/$uuid/ready-for-dispatch';
}
