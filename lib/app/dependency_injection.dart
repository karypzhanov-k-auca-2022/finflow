import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_factory.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/budgets/data/datasources/budget_local_data_source.dart';
import '../features/budgets/data/datasources/budget_remote_data_source.dart';
import '../features/budgets/data/repositories/budget_repository_impl.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';
import '../features/budgets/domain/usecases/budget_use_cases.dart';
import '../features/budgets/presentation/bloc/budgets_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/settings/data/settings_repository_impl.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/presentation/bloc/settings_cubit.dart';
import '../features/settings/presentation/bloc/theme_cubit.dart';
import '../features/transactions/data/datasources/transaction_local_data_source.dart';
import '../features/transactions/data/datasources/transaction_remote_data_source.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/domain/usecases/transaction_use_cases.dart';
import '../features/transactions/presentation/bloc/transaction_form_cubit.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
import 'app_initializer.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<BudgetRemoteDataSource>(
      () => BudgetRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(local: getIt(), remote: getIt()),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(local: getIt(), remote: getIt()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => TransactionUseCases(getIt()))
    ..registerLazySingleton(() => BudgetUseCases(getIt()))
    ..registerLazySingleton(() => AppInitializer(getIt(), getIt()))
    ..registerFactory(() => DashboardBloc(getIt(), getIt()))
    ..registerFactory(() => TransactionsBloc(getIt()))
    ..registerFactory(() => TransactionFormCubit(getIt()))
    ..registerFactory(() => BudgetsBloc(getIt(), getIt()))
    ..registerFactory(() => AnalyticsBloc(getIt()))
    ..registerFactory(() => ThemeCubit(getIt()))
    ..registerFactory(() => SettingsCubit(getIt(), getIt()));
}
