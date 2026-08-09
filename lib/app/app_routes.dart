abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const newTransaction = '/transactions/new';
  static const editTransaction = '/transactions/:id/edit';
  static const budgets = '/budgets';
  static const analytics = '/analytics';
  static const settings = '/settings';
  static const categories = '/categories';
  static const about = '/about';

  static String transactionEdit(String id) => '/transactions/$id/edit';
}
