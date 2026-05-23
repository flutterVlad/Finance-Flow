import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/data/models/category/category.dart';
import '/data/models/currency/currency.dart';
import '/data/models/expense/expense.dart';
import '/di.dart';
import '/l10n/app_localizations.dart';
import '/presentation/bloc/expense/expense_bloc.dart';
import '/utils/extensions.dart';
import '/utils/svgs/svg.dart';
import '/utils/theme.dart';
import '/utils/widgets/animated_text.dart';
import '/utils/widgets/app_bottom_sheet.dart';
import '/utils/widgets/primary_button.dart';
import '/utils/widgets/text_field_section.dart';
import '/utils/widgets/toast_service.dart';
import '/utils/widgets/vertical_picker.dart';
import 'bloc/input_forms.dart';
import 'bloc/transactions_cubit.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.isAddIncome = false,
    this.initialExpense,
  });

  final bool isAddIncome;

  final Expense? initialExpense;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final bloc = getIt<TransactionsCubit>();
  final homeBloc = getIt<ExpenseBloc>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();

    final date = widget.initialExpense?.datetime ?? DateTime.now();
    bloc.setDate(date);
    if (widget.isAddIncome) bloc.initIncomeTransaction();

    bloc.getCurrencyRate();
    bloc.setInitialExpense(widget.initialExpense);

    _nameController = TextEditingController(
      text: widget.initialExpense?.name.trim(),
    );
    _amountController = TextEditingController(
      text: widget.initialExpense?.price.toString(),
    );
    _categoryController = TextEditingController(
      text: widget.initialExpense?.category.name,
    );
    _dateController = TextEditingController();
    _timeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dateController.text = DateFormat(
        'd MMMM y',
        S.of(context).localeName,
      ).format(date);
      _timeController.text = DateFormat(
        'HH:mm',
        S.of(context).localeName,
      ).format(date);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: FittedBox(
            child: Text(
              s.addTransaction,
              style: const TextStyle(fontWeight: .bold),
            ),
          ),
          actionsPadding: const .only(right: 16),
          actions: const [_CurrencyAction()],
        ),
        body: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const .all(16),
                child: Form(
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: 16,
                    children: [
                      Section(
                        controller: _nameController,
                        title: s.transactionName,
                        hintText: s.tripToTurkey,
                        keyboardType: .text,
                        onSubmit: bloc.setName,
                        errorText: _inputErrorText(
                          state.nameInput.displayError,
                          context,
                        ),
                      ),
                      Section(
                        controller: _amountController,
                        title: s.amount,
                        hintText: '120',
                        suffixIcon: VerticalPicker<Currency>(
                          onSelected: bloc.setCurrency,
                          items: Currency.values,
                          initialItem: .byn,
                          builder: (el) {
                            final isSelected = el == state.selectedCurrency;

                            return TweenAnimationBuilder(
                              tween: ColorTween(
                                begin: isSelected ? Colors.grey : Colors.black,
                                end: isSelected ? Colors.black : Colors.grey,
                              ),
                              duration: const Duration(milliseconds: 200),
                              builder: (_, color, _) =>
                                  Svg(el.icon, color: color, size: 16),
                            );
                          },
                        ),
                        errorText: _inputErrorText(
                          state.amountInput.displayError,
                          context,
                        ),
                        keyboardType: const .numberWithOptions(decimal: true),
                        inputFormatters: [
                          TextInputFormatter.withFunction((_, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.replaceAll(',', '.'),
                            );
                          }),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onSubmit: bloc.setAmount,
                      ),
                      Section(
                        controller: _categoryController,
                        onTap: () async {
                          await _chooseCategory(context);
                        },
                        title: s.category,
                        hintText: state.categoryInput.value.name,
                        errorText: _inputErrorText(
                          state.categoryInput.displayError,
                          context,
                        ),
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.grey,
                        ),
                        prefixIcon: Svg(
                          state.categoryInput.value.iconAsset,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      Section(
                        title: s.date,
                        controller: _dateController,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.grey,
                        ),
                        errorText: _inputErrorText(
                          state.datetimeInput.displayError,
                          context,
                        ),
                        onTap: () {
                          AppBottomSheet.showDatePicker(
                            context: context,
                            mode: .date,
                            initialDateTime: state.datetimeInput.value,
                            onDateTimeChanged: (date) {
                              _dateController.text = DateFormat(
                                'd MMMM y',
                                s.localeName,
                              ).format(date);
                              bloc.setDate(
                                state.datetimeInput.value.copyWith(
                                  day: date.day,
                                  month: date.month,
                                  year: date.year,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Section(
                        title: s.time,
                        controller: _timeController,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.grey,
                        ),
                        errorText: _inputErrorText(
                          state.datetimeInput.displayError,
                          context,
                        ),
                        onTap: () {
                          AppBottomSheet.showDatePicker(
                            context: context,
                            mode: .time,
                            header: s.chooseTime,
                            initialDateTime: state.datetimeInput.value,
                            onDateTimeChanged: (date) {
                              _timeController.text = DateFormat(
                                'HH:mm',
                                s.localeName,
                              ).format(date);
                              bloc.setDate(
                                state.datetimeInput.value.copyWith(
                                  hour: date.hour,
                                  minute: date.minute,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SafeArea(
                        child: Section(
                          title: s.income,
                          enabled: !state.isIncomeCategorySelected,
                          boolValue: state.isIncome,
                          isBool: true,
                          onBoolChange: (newBool) {
                            bloc.setIncome(newBool);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const .all(16),
            child: BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: widget.initialExpense == null
                      ? s.createTransaction
                      : s.editTransaction,
                  enabled:
                      state.isFormValid &&
                      state.isExpenseEdited(widget.initialExpense),
                  onTap: () {
                    if (widget.initialExpense == null) {
                      homeBloc.add(.addExpense(state.validExpense));
                      ToastService.showToast(
                        message: s.expenseNameCreated(
                          state.validExpense.name,
                          state.isIncome ? 'income' : 'expense',
                          state.isIncome ? s.income : s.expense,
                        ),
                      );
                    } else {
                      homeBloc.add(
                        .updateExpense(
                          state.validExpense.copyWith(
                            accountId: widget.initialExpense?.accountId,
                          ),
                        ),
                      );
                      ToastService.showToast(
                        message: s.expenseEdited(state.validExpense.name),
                      );
                    }
                    if (context.canPop()) context.pop();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String? _inputErrorText(
    TransactionInputError? error,
    BuildContext context,
  ) {
    final s = S.of(context);

    return switch (error) {
      TransactionInputError.empty => s.fieldCanNotBeEmpty,
      TransactionInputError.invalid => s.valueInvalid,
      TransactionInputError.futureDate => s.futureDate,
      null => null,
    };
  }

  Future<void> _chooseCategory(BuildContext context) async {
    await AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      scaleFactor: 0.75,
      item: AppBottomSheet.chooseCategoryItem(
        context: context,
        categories: defaultCategories.sublist(
          0,
          defaultCategories.indexWhere((e) => e.isIncome),
        ),
        incomeCategory: defaultCategories.sublist(
          defaultCategories.indexWhere((e) => e.isIncome),
        ),
        onTap: (category) {
          bloc.setCategory(category);
          _categoryController.text = category.name;
        },
      ),
    );
  }
}

class _CurrencyAction extends StatelessWidget {
  const _CurrencyAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      buildWhen: (prev, curr) =>
          (prev.selectedCurrency != curr.selectedCurrency) ||
          (prev.rates != curr.rates),
      builder: (_, state) {
        final currency = state.getRate(state.selectedCurrency);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: state.rates.length > 1 ? AppColors.primary : AppColors.grey,
            borderRadius: .circular(16),
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              width: 70,
              height: 30,
              child: Center(
                child: AnimatedText(
                  text:
                      "${currency?.value.toCleanString() ?? ''} ${S.of(context).byn}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
