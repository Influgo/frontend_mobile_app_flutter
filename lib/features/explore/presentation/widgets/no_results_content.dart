import 'package:flutter/material.dart';

class NoResultsContent extends StatelessWidget {
  const NoResultsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/noSearchResults.png',
            width: 160,
            height: 160,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ups...',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No encontramos resultados que coincidan con tus criterios de búsqueda. Prueba con otros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
