import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import 'data/data_sources/local_datasource.dart';
import 'data/repositories/card_repository_impl.dart';
import 'data/repositories/currency_repository_impl.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/service/encryption_key_service.dart';
import 'data/service/hive_service.dart';
import 'data/service/image_picker.dart';
import 'data/service/secure_storage_service.dart';
import 'domain/repositories/card_repository.dart';
import 'domain/repositories/currency_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/use_cases/delete_account_use_case.dart';
import 'presentation/bloc/expense/expense_bloc.dart';
import 'presentation/bloc/settings/settings_bloc.dart';
import 'presentation/screens/actions_screen/features/add_transaction/bloc/transactions_cubit.dart';

final getIt = GetIt.instance;

class DI {
  Future<void> initDI() async {
    _initTalker();
    _initDio();
    await _initServices();
    _initRepositories();
    _initUseCases();
    _initBloc();
  }

  void _initBloc() {
    getIt.registerSingleton<SettingsBloc>(
      SettingsBloc(
        settingsRepository: getIt<SettingsRepository>(),
        cardRepository: getIt<CardRepository>(),
        deleteAccountUseCase: getIt<DeleteAccountUseCase>(),
      ),
    );
    getIt.registerLazySingleton<ExpenseBloc>(
      () => ExpenseBloc(
        expenseRepository: getIt<ExpenseRepository>(),
        settingsBloc: getIt<SettingsBloc>(),
      ),
    );
    getIt.registerFactory(
      () => TransactionsCubit(currencyRepository: getIt<CurrencyRepository>()),
    );
  }

  void _initTalker() {
    final talker = Talker(
      logger: TalkerLogger(output: (message) => log(message, name: 'Talker')),
    );
    getIt.registerSingleton<Talker>(talker);
    Bloc.observer = TalkerBlocObserver(
      talker: talker,
      settings: const .new(printStateFullData: false),
    );
  }

  void _initDio() {
    final dio = Dio(BaseOptions());
    getIt.registerSingleton<Dio>(dio);
    final talker = getIt<Talker>();
    dio.interceptors.add(TalkerDioLogger(talker: talker));
  }

  void _initRepositories() {
    getIt.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(hiveService: getIt<HiveService>()),
    );
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        hiveService: getIt<HiveService>(),
        imagePickerService: getIt<ImagePickerService>(),
      ),
    );
    getIt.registerLazySingleton<CardRepository>(
      () => CardRepositoryImpl(
        hiveService: getIt<HiveService>(),
        encryptionKeyService: getIt<EncryptionKeyService>(),
      ),
    );
    getIt.registerLazySingleton<CurrencyRepository>(
      () => CurrencyRepositoryImpl(dio: getIt<Dio>()),
    );
  }

  Future<void> _initServices() async {
    getIt.registerLazySingleton(() => const SecureStorageService());
    getIt.registerLazySingleton(
      () => EncryptionKeyService(secureStorage: getIt<SecureStorageService>()),
    );
    getIt.registerLazySingleton(() => const MockLocalService());
    getIt.registerLazySingleton(() => const ImagePickerService());
    getIt.registerLazySingleton(() => const HiveService());
    await getIt<HiveService>().init();
  }

  void _initUseCases() {
    getIt.registerLazySingleton(
      () => DeleteAccountUseCase(
        cardRepository: getIt<CardRepository>(),
        expenseRepository: getIt<ExpenseRepository>(),
        settingsRepository: getIt<SettingsRepository>(),
      ),
    );
  }
}
