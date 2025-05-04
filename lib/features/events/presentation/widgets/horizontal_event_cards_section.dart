import 'package:flutter/material.dart';

class HorizontalEventCardsSection extends StatelessWidget {
  final String title;
  final List<Widget> cards;

  const HorizontalEventCardsSection({
    super.key,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 206,
                child: cards[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
