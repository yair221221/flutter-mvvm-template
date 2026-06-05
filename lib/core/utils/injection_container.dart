import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/firebase_config.dart';
import '../../data/datasources/local/item_local_datasource.dart';
import '../../data/datasources/remote/item_remote_datasource.dart';
import '../../data/repositories/firebase_friends_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/decline_request_usecase.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../domain/usecases/get_wellness_score_usecase.dart';
import '../../presentation/viewmodels/dashboard_viewmodel.dart';
import '../../presentation/viewmodels/friends_viewmodel.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/user_viewmodel.dart';
import 'env_config.dart';

final sl = GetIt.instance;

Future<void> init({EnvConfig env = EnvConfig.development}) async {
  // -- External --------------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => Dio(
        BaseOptions(
          baseUrl: env.baseUrl,
          connectTimeout: Duration(milliseconds: env.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: env.receiveTimeoutMs),
        ),
      ));

  // -- Repositories ----------------------------------------------------------
  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<WellnessRepository>(
    () => WellnessRepositoryImpl(),
  );

  if (kFirebaseEnabled) {
    sl.registerLazySingleton<FriendsRepository>(
      () => FirebaseFriendsRepository(
        db: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );
    sl.registerLazySingleton<UserRepository>(
      () => FirebaseUserRepository(
        auth: FirebaseAuth.instance,
        db: FirebaseFirestore.instance,
        prefs: sl(),
      ),
    );
  } else {
    sl.registerLazySingleton<FriendsRepository>(
      () => FriendsRepositoryImpl(prefs: sl()),
    );
    // Stub UserRepository when Firebase is disabled
    sl.registerLazySingleton<UserRepository>(
      () => _NoOpUserRepository(),
    );
  }

  // -- Use Cases -------------------------------------------------------------
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetWellnessScoreUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendsUseCase(sl()));
  sl.registerLazySingleton(() => GetRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptRequestUseCase(sl()));
  sl.registerLazySingleton(() => DeclineRequestUseCase(sl()));

  // -- ViewModels ------------------------------------------------------------
  sl.registerFactory(() => HomeViewModel(getItems: sl()));
  sl.registerFactory(() => DashboardViewModel(
        getWellnessScore: sl(),
        repository: sl(),
      ));
  sl.registerFactory(() => FriendsViewModel(
        repository: sl(),
        getSuggestions: sl(),
        acceptRequest: sl(),
        declineRequest: sl(),
      ));
  sl.registerFactory(() => UserViewModel(repository: sl()));

  // -- Data Sources ----------------------------------------------------------
  sl.registerLazySingleton<ItemRemoteDataSource>(
    () => ItemRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ItemLocalDataSource>(
    () => ItemLocalDataSourceImpl(prefs: sl()),
  );
}

/// No-op UserRepository used when Firebase is disabled.
class _NoOpUserRepository implements UserRepository {
  @override
  Future<UserProfile?> getCurrentUser() async => null;

  @override
  Future<UserProfile> saveProfile({
    required String uid,
    required String displayName,
    required String avatarEmoji,
  }) async =>
      UserProfile(uid: uid, displayName: displayName, avatarEmoji: avatarEmoji);

  @override
  Future<bool> isFirstLaunch() async => false;
}
