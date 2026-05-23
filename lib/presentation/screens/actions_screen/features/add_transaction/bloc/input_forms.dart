import 'package:formz/formz.dart';

import '/data/models/category/category.dart';

enum TransactionInputError {
  empty,
  invalid,
  futureDate,
}

class TransactionNameInput extends FormzInput<String, TransactionInputError?> {
  const TransactionNameInput.pure({String value = ''}) : super.pure(value);

  const TransactionNameInput.dirty({String value = ''}) : super.dirty(value);

  @override
  TransactionInputError? validator(String value) {
    return value.isEmpty ? TransactionInputError.empty : null;
  }
}

class TransactionAmountInput
    extends FormzInput<String, TransactionInputError?> {
  const TransactionAmountInput.pure({String value = ''}) : super.pure(value);

  const TransactionAmountInput.dirty({String value = ''})
    : super.dirty(value);

  @override
  TransactionInputError? validator(String value) {
    if (value.isEmpty) return TransactionInputError.empty;
    if (double.tryParse(value)?.isNegative ?? false) {
      return TransactionInputError.invalid;
    }
    return null;
  }
}

class TransactionCategoryInput
    extends FormzInput<Category, TransactionInputError?> {
  const TransactionCategoryInput.pure({Category value = Category.empty})
    : super.pure(value);

  const TransactionCategoryInput.dirty({Category value = Category.empty})
    : super.dirty(value);

  @override
  TransactionInputError? validator(Category value) {
    return value == Category.empty ? TransactionInputError.empty : null;
  }
}

class TransactionDateTimeInput
    extends FormzInput<DateTime, TransactionInputError?> {
  TransactionDateTimeInput.pure({DateTime? value})
    : super.pure(value ?? DateTime.now());

  TransactionDateTimeInput.dirty({DateTime? value})
    : super.dirty(value ?? DateTime.now());

  @override
  TransactionInputError? validator(DateTime value) {
    return value.isAfter(DateTime.now())
        ? TransactionInputError.futureDate
        : null;
  }
}
