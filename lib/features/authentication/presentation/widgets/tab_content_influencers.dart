import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/business_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/horizontal_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/scrollable_filters.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/no_results_content.dart';

class TabContentInfluencers extends StatefulWidget {
  const TabContentInfluencers({super.key});

  @override
  _TabContentInfluencersState createState() => _TabContentInfluencersState();
}

class _TabContentInfluencersState extends State<TabContentInfluencers> {
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: HorizontalCardsSection(
                  title: "Más recientes",
                  cards: [
                    /*
                    BusinessCardWidget(),
                    BusinessCardWidget(),
                    BusinessCardWidget(),*/
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: HorizontalCardsSection(
                  title: "Más colaboraciones",
                  cards: [
                    /*
                    BusinessCardWidget(),
                    BusinessCardWidget(),
                    BusinessCardWidget(),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
