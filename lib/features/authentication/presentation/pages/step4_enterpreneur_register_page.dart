// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
// import 'package:flutter_camera_overlay/model.dart';
// import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';

// class CustomIDScanner extends StatefulWidget {
//   const CustomIDScanner({Key? key}) : super(key: key);

//   @override
//   _CustomIDScannerState createState() => _CustomIDScannerState();
// }

// class _CustomIDScannerState extends State<CustomIDScanner> {
//   XFile? capturedImage;
//   bool isImageCaptured = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
     
//           Positioned.fill(
//             child: FutureBuilder<List<CameraDescription>?>(
//               future: availableCameras(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   if (snapshot.data == null) {
//                     return const Center(
//                       child: Text('No camera found'),
//                     );
//                   }
//                   return CameraOverlay(
//                     snapshot.data!.first,
//                     CardOverlay.byFormat(OverlayFormat.cardID3),
//                     (XFile file) {
//                       setState(() {
//                         capturedImage = file;
//                         isImageCaptured = true;
//                       });
//                     },
//                     info: 'Enfoca mejor el documento de identidad',
//                     label: 'Frente de tu DNI',
//                   );
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               },
//             ),
//           ),
          
     
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.white,
//               padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.black),
//                         onPressed: () => Navigator.of(context).pop(),
//                       ),
//                       const Spacer(),
//                       SvgPicture.asset(
//                         'assets/images/influyo_logo.svg',
//                         height: 25,
//                       ),
//                       const Spacer(),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0,
//                       vertical: 40,
//                     ),
//                     child: Row(
//                       children: [
//                         for (int i = 0; i < 3; i++) ...[
//                           if (i > 0) const SizedBox(width: 8),
//                           Expanded(
//                             child: Container(
//                               height: 4,
//                               decoration: const BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Color(0xFFC20B0C),
//                                     Color(0xFF7E0F9D),
//                                     Color(0xFF2616C7),
//                                   ],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(2)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom button
//           if (isImageCaptured)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => setState(() {
//                       isImageCaptured = false;
//                       capturedImage = null;
//                     }),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: const Text(
//                       'Tomar otra foto',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Handle the captured image
//                       if (capturedImage != null) {
                     
//                         print('Image captured: ${capturedImage!.path}');
//                       }
//                       RegisterPage.goToNextStep(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: const Text(
//                       'Continuar',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }