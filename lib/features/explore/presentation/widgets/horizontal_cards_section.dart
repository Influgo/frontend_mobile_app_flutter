import 'package:flutter/material.dart';

class HorizontalCardsSection extends StatelessWidget {
  final String title;
  final List<Widget> cards;

  const HorizontalCardsSection({
    super.key,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Lista horizontal de tarjetas
        SizedBox(
          height: 190, // Aumentamos para darle espacio a la tarjeta
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150, // Asegura que la tarjeta no se desborde en ancho
                child: cards[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
