class ApiConfig {
  // Development URLs
  static const String devBaseUrl = 'http://localhost:4000/api';
  static const String devServerUrl = 'http://localhost:4000';
  
  // Production URLs (update these with your actual server URLs)
  static const String prodBaseUrl = 'https://your-production-server.com/api';
  static const String prodServerUrl = 'https://your-production-server.com';
  
  // Mobile development URLs (update with your computer's IP address)
  static const String mobileDevBaseUrl = 'http://192.168.2.63:4000/api';
  static const String mobileDevServerUrl = 'http://192.168.2.63:4000';
  
  // Get the appropriate base URL based on environment
  static String get baseUrl {
    // You can set this via environment variable or build configuration
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    
    switch (environment) {
      case 'prod':
        return prodBaseUrl;
      case 'mobile':
        return mobileDevBaseUrl;
      default:
        return devBaseUrl;
    }
  }
  
  static String get serverUrl {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    
    switch (environment) {
      case 'prod':
        return prodServerUrl;
      case 'mobile':
        return mobileDevServerUrl;
      default:
        return devServerUrl;
    }
  }
  
  // Helper method to get full API endpoint
  static String getEndpoint(String path) {
    return '$baseUrl/$path';
  }
}
