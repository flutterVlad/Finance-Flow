import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/data/models/expense/expense.dart';
import '/l10n/app_localizations.dart';
import '/presentation/bloc/expense/expense_bloc.dart';
import '/utils/extensions.dart';
import '/utils/svgs/svg.dart';
import '/utils/theme.dart';
import '/utils/widgets/animated_text.dart';
import '../widgets/date_filter.dart';

class SpentStatistics extends StatelessWidget {
  const SpentStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return CustomScrollView(
      slivers: [
        const DateFilter(),
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) => Diagram(
            expenses: state.expenseOnSelectedMonth,
            allSpends: state.spendsOnSelectedMonth,
            title: s.allSpends,
          ),
        ),
        BlocBuilder<ExpenseBloc, ExpenseState>(
          buildWhen: (prev, curr) => !const ListEquality().equals(
            prev.expenseOnSelectedMonth,
            curr.expenseOnSelectedMonth,
          ),
          builder: (context, state) => StatisticDetails(
            title: s.spent,
            addedElement: s.spend,
            amount: state.spendsOnSelectedMonth,
            expenses: state.expenseOnSelectedMonth,
            onAdd: () => context.pushNamed('add_transaction'),
          ),
        ),
      ],
    );
  }
}

class IncomeStatistics extends StatelessWidget {
  const IncomeStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return CustomScrollView(
      slivers: [
        const DateFilter(),
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) => Diagram(
            expenses: state.incomeOnSelectedMonth,
            allSpends: state.incomesOnSelectedMonth,
            title: S.of(context).allIncomes,
          ),
        ),
        BlocBuilder<ExpenseBloc, ExpenseState>(
          buildWhen: (prev, curr) => !const ListEquality().equals(
            prev.incomeOnSelectedMonth,
            curr.incomeOnSelectedMonth,
          ),
          builder: (context, state) => StatisticDetails(
            title: s.incomes,
            addedElement: s.income,
            amount: state.incomesOnSelectedMonth,
            expenses: state.incomeOnSelectedMonth,
            onAdd: () => context.pushNamed('add_transaction', extra: true),
          ),
        ),
      ],
    );
  }
}

class Diagram extends StatefulWidget {
  const Diagram({
    super.key,
    required this.expenses,
    required this.allSpends,
    required this.title,
  });

  final List<GroupedExpense> expenses;
  final double allSpends;
  final String title;

  @override
  State<Diagram> createState() => _DiagramState();
}

class _DiagramState extends State<Diagram> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final centerSpaceRadius = MediaQuery.widthOf(context) / 5;
    final s = S.of(context);

    if (widget.allSpends == 0) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const .all(16.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Center(child: Text(s.noDataInThisMonth)),
          ),
        ),
      );
    }

    final price = touchedIndex != -1
        ? widget.expenses[touchedIndex].formattedAmount
        : widget.allSpends.toCleanString();

    final title = touchedIndex != -1
        ? widget.expenses[touchedIndex].category.name
        : widget.title;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .all(16),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(
            fit: .expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    AnimatedText(text: '$price ${s.byn}'),
                    AnimatedText(
                      text: title,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              PieChart(
                PieChartData(
                  startDegreeOffset: 90,
                  sectionsSpace: 2,
                  centerSpaceRadius: centerSpaceRadius,
                  sections: widget.expenses
                      .map(
                        (e) => _makeSectionData(
                          expense: e,
                          radius: centerSpaceRadius / 2.5,
                          isTouched: widget.expenses.indexOf(e) == touchedIndex,
                        ),
                      )
                      .toList(),
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;

                      if (response == null || response.touchedSection == null) {
                        setState(() => touchedIndex = -1);
                        return;
                      }

                      final tappedIndex =
                          response.touchedSection!.touchedSectionIndex;

                      if (tappedIndex == touchedIndex) {
                        setState(() => touchedIndex = -1);
                        return;
                      }

                      setState(() => touchedIndex = tappedIndex);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _makeSectionData({
    required GroupedExpense expense,
    bool isTouched = false,
    double radius = 30,
  }) {
    return PieChartSectionData(
      value: expense.amount,
      color: expense.category.color,
      showTitle: false,
      borderSide: BorderSide(
        width: isTouched ? 2 : 0,
        color: expense.category.color!.darken(),
      ),
      radius: isTouched ? radius + 10 : radius,
      titleStyle: const TextStyle(color: AppColors.grey, fontSize: 12),
      title: '${expense.formattedAmount}\n${expense.category.name}',
      titlePositionPercentageOffset: 1.8,
    );
  }
}

class StatisticDetails extends StatelessWidget {
  const StatisticDetails({
    super.key,
    required this.title,
    required this.amount,
    required this.expenses,
    required this.onAdd,
    required this.addedElement,
  });

  final String title;
  final String addedElement;
  final double amount;
  final List<GroupedExpense> expenses;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .all(16),
        child: Material(
          borderRadius: .circular(16),
          child: Padding(
            padding: const .all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: .bold)),
                    Text(
                      '${amount.toCleanString()} ${s.byn}',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
                Padding(
                  padding: const .symmetric(vertical: 8.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: .zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index + 1 == expenses.length + 1) {
                        return _Element(
                          elementName: addedElement,
                          onTap: onAdd,
                        );
                      }
                      return _Element(expense: expenses[index]);
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.grey.withValues(alpha: 0.5),
                      height: 20,
                      indent: 5,
                      endIndent: 5,
                    ),
                    itemCount: expenses.length + 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Element extends StatelessWidget {
  const _Element({this.expense, this.elementName = '', this.onTap});
  final GroupedExpense? expense;
  final String elementName;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (expense != null) {
      return GestureDetector(
        onTap: onTap,
        child: Row(
          spacing: 8,
          children: [
            Svg(
              expense!.category.iconAsset,
              color: expense!.category.color,
              size: 30,
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(expense!.category.name),
                Text(
                  '${expense!.formattedAmount} ${s.byn}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Row(
        spacing: 8,
        children: [
          const Svg(Svgs.addRounded, color: AppColors.grey, size: 30),
          Text(s.addItem(elementName.toLowerCase())),
        ],
      ),
    );
  }
}
