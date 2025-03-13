import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountUnderReviewModal extends StatelessWidget {
  final VoidCallback onClose;

  const AccountUnderReviewModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),

        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85, 
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15), 
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: onClose,
                    child: SvgPicture.asset(
                      'assets/icons/closeicon.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Stack(
                  alignment: Alignment.center,
                  children: [
                  SvgPicture.asset(
                    'assets/icons/revisionicon.svg',
                    width: 140,
                    height: 140,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 30.0), // Added bottom padding
                    child: Image.asset(
                    'assets/images/review.gif',
                    width: 280,
                    height: null,
                    fit: BoxFit.contain,
                    ),
                  ),
                  ],
                ),

                SizedBox(height: 15),

                Text(
                  '¡Tu cuenta está en revisión!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF3D3D67), 
                    decoration: TextDecoration.none, 
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10),

                Text(
                  'Este proceso puede tardar hasta 24 horas. Te avisaremos cuando estés verificado para que puedas acceder a la opción de calendario.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF717191), 
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 25), 

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF222222), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), 
                      ),
                      padding: EdgeInsets.symmetric(vertical: 24),
                    ),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.white, 
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
