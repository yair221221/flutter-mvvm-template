import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/item_local_datasource.dart';
import '../../data/datasources/remote/item_remote_datasource.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/get_wellness_score_usecase.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/dashboard_viewmodel.dart';
import 'env_config.dart';

final sl = GetIt.instance;

Future<void> init({EnvConfig env = EnvConfig.development}) async {
  // ViewModels
  sl.registerFactory(() => HomeViewModel(getItems: sl()));
  sl.registerFactory(() => DashboardViewModel(
        getWellnessScore: sl(),
        repository: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetWellnessScoreUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<WellnessRepository>(
    () => WellnessRepositoryImpl(),
  );

  // Data Sources
  sl.registerLazySingleton<ItemRemoteDataSource>(
    () => ItemRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ItemLocalDataSource>(
    () => ItemLocalDataSourceImpl(prefs: sl()),
  );

  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => Dio(
        BaseOptions(
          baseUrl: env.baseUrl,
          connectTimeout: Duration(milliseconds: env.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: env.receiveTimeoutMs),
        ),
      ));
}
