import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/utils/theme.dart';
import '/utils/widgets/page_keep_alive_wrapper.dart';
import 'features/spent_statistics/spent_statistics.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(s.budget, style: const TextStyle(fontWeight: .bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: .circular(30),
                color: AppColors.primary,
              ),
              child: TabBar(
                indicatorPadding: const .all(4),
                tabs: [
                  TabItem(text: s.income, height: 30, width: 70),
                  TabItem(text: s.expenses, height: 30, width: 70),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PageKeepAliveWrapper(child: IncomeStatistics()),
            PageKeepAliveWrapper(child: SpentStatistics()),
          ],
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({super.key, this.text = '', this.width, this.height});
  final String text;

  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Tab(text: text, height: height),
    );
  }
}
