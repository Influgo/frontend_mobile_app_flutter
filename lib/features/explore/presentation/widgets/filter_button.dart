import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive; // ← NUEVO PARÁMETRO

  const FilterButton({
    super.key,
    required this.onPressed,
    this.isActive = false, // ← VALOR POR DEFECTO
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // ← CAMBIO DE COLOR BASADO EN EL ESTADO
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
            // ← CAMBIO DE COLOR DEL ÍCONO BASADO EN EL ESTADO
            isActive ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
