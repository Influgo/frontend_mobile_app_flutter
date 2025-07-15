import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final int? filterCount; // ← NUEVO PARÁMETRO para el número de filtros

  const FilterButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
    this.filterCount, // ← Parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 4.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Botón principal
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.black : Colors.white,
                foregroundColor: isActive ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.black),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: SvgPicture.asset(
                'assets/icons/filtericon.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Contador de filtros (solo se muestra si filterCount > 0)
          if (filterCount != null && filterCount! > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFC20B0C), // C20B0C
                      Color(0xFF7E0F9D), // 7E0F9D
                      Color(0xFF2616C7), // 2616C7
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    filterCount! > 99 ? '99+' : filterCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
