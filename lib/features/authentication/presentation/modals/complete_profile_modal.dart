import 'dart:ui';
import 'package:flutter/material.dart';

class CompleteProfileModal extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCompleteProfile;
  final String userRole; // "INFLUENCER" o "ENTREPRENEUR"

  const CompleteProfileModal({
    super.key, 
    required this.onClose,
    required this.onCompleteProfile,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isInfluencer = userRole.toUpperCase() == 'INFLUENCER';
    final profileType = isInfluencer ? 'influencer' : 'emprendimiento';
    final buttonText = isInfluencer ? 'Crear perfil de influencer' : 'Crear perfil de emprendimiento';
    
    return GestureDetector(
      onTap: onClose,
      child: Stack(
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
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping the modal content
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
                    SizedBox(height: 25),
                    
                    Image.asset(
                      'assets/images/alert.png',
                      width: 140,
                      height: 140,
                    ),

                SizedBox(height: 25),

                Text(
                  'Antes de acceder a la opción de chat primero debes completar tu perfil de $profileType.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
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
                    onPressed: onCompleteProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF222222), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), 
                      ),
                      padding: EdgeInsets.symmetric(vertical: 24),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.white, 
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}