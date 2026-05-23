part of 'expense_bloc.dart';

@freezed
abstract class ExpenseState with _$ExpenseState {
  const ExpenseState._();

  const factory ExpenseState({
    String? accountId,
    @Default([]) List<DayExpense> allDayExpenses,
    @Default([]) List<Expense> allExpenses,
    @Default([]) List<Expense> incomes,
    required DateTime monthFilter,
  }) = _ExpenseState;

  List<Expense> get monthExpenses =>
      allExpenses.where((e) => e.datetime.isCurrentMonth).toList();

  List<Expense> get monthIncomes =>
      incomes.where((e) => e.datetime.isCurrentMonth).toList();

  double get monthBalance => monthIncomes.fold(0, (a, b) => a + b.price);

  double get balanceOnSelectedMonth => incomes
      .where((e) => e.datetime.isSelectedMonth(monthFilter))
      .fold(0, (a, b) => a + b.price);

  double get percent {
    if (monthBalance == 0 && monthSpends == 0) {
      return 0;
    } else if (monthBalance == 0 && monthSpends != 0) {
      return 1.01;
    } else {
      return monthSpends / monthBalance;
    }
  }

  double get monthSpends => monthExpenses.fold(0, (a, b) => a + b.price);

  double get remains => monthBalance - monthSpends;

  List<GroupedExpense> get expenseOnSelectedMonth {
    final expenses = allExpenses.where(
      (e) => e.datetime.isSelectedMonth(monthFilter),
    );

    return _unionByCat(expenses.toList());
  }

  double get spendsOnSelectedMonth =>
      expenseOnSelectedMonth.fold(0, (a, b) => a + b.amount);

  List<GroupedExpense> get incomeOnSelectedMonth {
    final monthIncomes = incomes.where(
      (e) => e.datetime.isSelectedMonth(monthFilter),
    );

    return _unionByCat(monthIncomes.toList());
  }

  double get incomesOnSelectedMonth =>
      incomeOnSelectedMonth.fold(0, (a, b) => a + b.amount);

  List<DayExpense> get curWeekDayExpenses {
    final today = DateTime.now();

    final result = List.generate(7, (i) => DayExpense(date: today));

    final weekExp = allDayExpenses
        .where(
          (e) =>
              e.date.isBefore(
                today.endOfWeek.subtract(const Duration(days: 1)),
              ) &&
              e.date.isAfter(
                today.startOfWeek.subtract(const Duration(days: 1)),
              ),
        )
        .toList();

    for (final dayExp in weekExp) {
      result[dayExp.date.weekday - 1] = dayExp;
    }

    return result;
  }

  List<Expense> get curWeekExpenses => allExpenses
      .where(
        (e) =>
            e.datetime.isAfter(
              DateTime.now().startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            e.datetime.isBefore(
              DateTime.now().endOfWeek.subtract(const Duration(days: 1)),
            ),
      )
      .toList();

  double get maxWeekSpends => curWeekDayExpenses.isNotEmpty
      ? curWeekDayExpenses
            .reduce((a, b) => a.daySpend > b.daySpend ? a : b)
            .daySpend
      : 0;

  List<Expense> get todayExpenses => allDayExpenses
      .where((e) => e.date.isToday)
      .fold([], (a, b) => a + b.dayExpenses);

  List<DayExpense> get filteredDayExpenses =>
      allDayExpenses.where((e) => e.date.isSelectedMonth(monthFilter)).toList();

  List<GroupedExpense> getGroupedExpenseByDate(DateTime date) {
    final expenses = allExpenses
        .where((e) => e.datetime.inWeekend(date))
        .toList();

    return _unionByCat(expenses);
  }

  List<GroupedExpense> _unionByCat(List<Expense> items) {
    final Map<String, List<Expense>> tempExpenseMap = {};

    for (final expense in items) {
      if (tempExpenseMap.keys.contains(expense.category.name)) {
        tempExpenseMap[expense.category.name]?.add(expense);
      } else {
        tempExpenseMap[expense.category.name] = [expense];
      }
    }

    final groups = tempExpenseMap.values.map(GroupedExpense.fromList).toList();
    groups.sort((a, b) => b.amount.compareTo(a.amount));

    return groups;
  }
}
