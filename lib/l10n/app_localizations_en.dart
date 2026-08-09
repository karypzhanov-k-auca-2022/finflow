// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FinFlow';

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String routeDoesNotExist(String route) {
    return 'Route $route does not exist';
  }

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get backToTransactions => 'Back to transactions';

  @override
  String get loadingData => 'Loading data…';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get pleaseTryAgain => 'Please try again';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get undo => 'Undo';

  @override
  String get apply => 'Apply';

  @override
  String get refresh => 'Refresh';

  @override
  String get offlineTitle => 'You are offline';

  @override
  String get offlineMessage =>
      'Internet access is unavailable. Your saved finance data remains available on this device.';

  @override
  String get continueOffline => 'Continue offline';

  @override
  String get checkAgain => 'Check again';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get filters => 'Filters';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get searchTransactions => 'Search by title or note';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsMessage =>
      'Add your first transaction to start tracking your finances.';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get nothingFoundMessage => 'Change the search query or filters.';

  @override
  String get filtersAndSorting => 'Filters & sorting';

  @override
  String get all => 'All';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get expenses => 'Expenses';

  @override
  String get category => 'Category';

  @override
  String get allCategories => 'All categories';

  @override
  String get period => 'Period';

  @override
  String get allTime => 'All time';

  @override
  String get currentMonth => 'Current month';

  @override
  String get threeMonths => '3 months';

  @override
  String get sixMonths => '6 months';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get selectRange => 'Select range';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get sortBy => 'Sort by';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get direction => 'Direction';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get deleteTransactionQuestion => 'Delete transaction?';

  @override
  String transactionCannotBeRestored(String title) {
    return '\"$title\" cannot be restored.';
  }

  @override
  String transactionDeleted(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get exitWithoutSaving => 'Exit without saving?';

  @override
  String get changesWillBeLost => 'Changes will be lost.';

  @override
  String get stay => 'Stay';

  @override
  String get exit => 'Exit';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get title => 'Title';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get enterPositiveAmount => 'Enter a positive amount';

  @override
  String get createCategory => 'Create category';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get dashboardNoTransactions => 'No transactions yet';

  @override
  String get dashboardNoTransactionsMessage =>
      'Add your first transaction — an overview will appear here.';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get budgetForPeriod => 'Budget for period';

  @override
  String spentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get expensesByCategory => 'Expenses by category';

  @override
  String get noExpenses => 'No expenses';

  @override
  String get noExpensesForPeriod => 'No expenses for the selected period yet.';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get averageExpenses => 'Average expenses';

  @override
  String get monthlyExpenses => 'Monthly expenses';

  @override
  String get topCategory => 'Top category';

  @override
  String get notEnoughData => 'Not enough data';

  @override
  String get addExpensesForAnalytics => 'Add expenses to see analytics.';

  @override
  String get byCategory => 'By category';

  @override
  String get account => 'Account';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get guestAccount => 'Guest account';

  @override
  String get dataStoredOnThisDevice => 'Signed in; data stored on this device';

  @override
  String get signOut => 'Sign out';

  @override
  String get signIn => 'Sign in';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get manageCategoriesSubtitle => 'View and create categories';

  @override
  String get data => 'Data';

  @override
  String get exportTransactionsCsv => 'Export transactions to CSV';

  @override
  String get exportTransactionsCsvSubtitle => 'Save or copy financial records';

  @override
  String get clearData => 'Clear data';

  @override
  String get clear => 'Clear';

  @override
  String get restore => 'Restore';

  @override
  String get dataCleared => 'Data cleared';

  @override
  String get demoDataRestored => 'Demo data restored';

  @override
  String get clearDataSubtitle => 'Delete transactions and budgets';

  @override
  String get clearAllDataQuestion => 'Clear all data?';

  @override
  String get clearAllDataMessage =>
      'Transactions, budgets, and custom categories will be deleted from this device.';

  @override
  String get restoreDemoData => 'Restore demo data';

  @override
  String get restoreDemoDataSubtitle =>
      'Replace current data with the sample dataset';

  @override
  String get restoreDemoDataQuestion => 'Restore demo data?';

  @override
  String get restoreDemoDataMessage =>
      'Current transactions and budgets will be replaced.';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App version';

  @override
  String get deviceModel => 'Model';

  @override
  String get osVersion => 'OS version';

  @override
  String get deviceInfoLoadError => 'Could not load device information';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String csvGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generated $count transactions in CSV format:',
      one: 'Generated 1 transaction in CSV format:',
      zero: 'No transactions generated',
    );
    return '$_temp0';
  }

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get csvCopied => 'CSV copied to clipboard!';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryTransfers => 'Transfers';

  @override
  String get newCategory => 'New category';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get noCategories => 'No categories';

  @override
  String get noCategoriesMessage =>
      'Create your first category to track finances.';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get enterCategoryName => 'Enter category name';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get deleteCategoryQuestion => 'Delete category?';

  @override
  String categoryWillBeDeleted(String name) {
    return 'Category \"$name\" will be deleted.';
  }

  @override
  String get newBudget => 'New budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get editLimit => 'Edit limit';

  @override
  String get categoryTransactions => 'Category Transactions';

  @override
  String get failedToLoadTransactions => 'Failed to load transactions';

  @override
  String get noCategoryExpensesThisMonth =>
      'No expense transactions found for this category this month.';

  @override
  String get noBudgets => 'No budgets set';

  @override
  String get noBudgetsMessage =>
      'Set a limit for a category and track progress.';

  @override
  String get createBudget => 'Create budget';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get enterPositiveLimit => 'Enter a positive limit';

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get deleteBudgetQuestion => 'Delete budget?';

  @override
  String budgetWillBeRemoved(String name) {
    return 'Limit for category \"$name\" will be removed.';
  }

  @override
  String budgetDeleted(String name) {
    return 'Budget for \"$name\" deleted';
  }

  @override
  String get limitWillBeRemoved => 'Limit for this category will be removed.';

  @override
  String limitExceededBy(String amount) {
    return 'Limit exceeded by $amount';
  }

  @override
  String get budgetOverEightyPercent => 'More than 80% of budget used';

  @override
  String remainingAmount(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get personalFinanceTracker =>
      'Personal Finance Tracker • version 1.0.0';

  @override
  String get aboutDescription =>
      'A personal finance tracker built with offline-first storage, Clean Architecture, BLoC, GoRouter, Dio, and automated tests.';

  @override
  String get login => 'Sign in';

  @override
  String get registration => 'Registration';

  @override
  String get createAccountTitle => 'Create a FinFlow account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get registerSubtitle => 'Create a personal profile for your finances';

  @override
  String get loginSubtitle => 'Sign in to access your personal finances';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordMinLength => 'Password must contain at least 6 characters';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loading => 'Loading…';

  @override
  String get registerAction => 'Register';

  @override
  String get signInAction => 'Sign in to account';

  @override
  String get or => 'OR';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get continueAsGuestOffline => 'Continue as guest (offline mode)';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get storageInitializationFailed => 'Failed to prepare local storage';
}
