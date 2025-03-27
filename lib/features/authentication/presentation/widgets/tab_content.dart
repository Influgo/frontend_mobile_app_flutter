import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/scrollable_filters.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/no_results_content.dart';

class TabContent extends StatefulWidget {
  const TabContent({Key? key}) : super(key: key);

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  String _selectedCategory = "Todos";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScrollableFilters(
          selectedCategory: _selectedCategory,
          onCategorySelected: (newCategory) {
            setState(() {
              _selectedCategory = newCategory;
            });
          },
        ),
        const Expanded(child: NoResultsContent()),
      ],
    );
  }
}
