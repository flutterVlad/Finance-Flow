import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '/data/models/category/category.dart';
import '/data/models/currency/currency.dart';
import '/data/models/expense/expense.dart';
import '/domain/repositories/currency_repository.dart';
import '/presentation/screens/actions_screen/features/add_transaction/bloc/input_forms.dart';
import '/utils/extensions.dart';

part 'transactions_cubit.freezed.dart';
part 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({required CurrencyRepository currencyRepository})
    : _currencyRepository = currencyRepository,
      super(
        TransactionsState(
          datetimeInput: .dirty(value: DateTime.now()),
          categoryInput: .dirty(value: defaultCategories[3]),
        ),
      );
  final CurrencyRepository _currencyRepository;

  FutureOr<void> getCurrencyRate() async {
    if (state.rates.isNotEmpty && state.rates.first.date.isToday) return;

    final responseRates = await _currencyRepository.fetchRates();
    final rates = [
      Rate.blrRate,
      ...responseRates.where(
        (e) =>
            e.shortName == 'USD' ||
            e.shortName == 'EUR' ||
            e.shortName == 'TRY',
      ),
    ];

    emit(state.copyWith(rates: rates));
  }

  void setCurrency(Currency cur) => emit(state.copyWith(selectedCurrency: cur));

  void setName(String? name) {
    emit(state.copyWith(nameInput: .dirty(value: name ?? '')));
  }

  void setInitialExpense(Expense? expense) {
    if (expense == null) return;

    emit(
      state.copyWith(
        id: expense.id,
        nameInput: .pure(value: expense.name.trim()),
        amountInput: .pure(value: expense.price.toString()),
        categoryInput: .pure(value: expense.category),
        datetimeInput: .pure(value: expense.datetime),
        isIncome: expense.isIncome,
      ),
    );
  }

  void initIncomeTransaction() {
    emit(
      state.copyWith(
        isIncome: true,
        categoryInput: .dirty(
          value: defaultCategories.firstWhere((e) => e.id == 33),
        ),
      ),
    );
  }

  void setAmount(String? amount) {
    emit(state.copyWith(amountInput: .dirty(value: amount ?? '')));
  }

  void setCategory(Category category) {
    emit(
      state.copyWith(
        categoryInput: .dirty(value: category),
        isIncome: category.isIncome,
      ),
    );
  }

  void setDate(DateTime date) =>
      emit(state.copyWith(datetimeInput: .dirty(value: date)));

  void setIncome(bool newBool) => emit(state.copyWith(isIncome: newBool));
}
