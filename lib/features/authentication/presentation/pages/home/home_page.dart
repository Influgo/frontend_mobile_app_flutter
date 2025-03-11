import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/explora/explora_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ExploraPage(),

    Center(child: Text('Calendario')),
    Center(child: Text('Eventos')),
    Center(child: Text('Chat')),
    ProfileScreen(),
  ];

  // Lista de rutas para los iconos SVG
  final List<String> _iconPaths = [
    'assets/icons/exploraicon.svg',
    'assets/icons/calendarioicon.svg',
    'assets/icons/eventosicon.svg',
    'assets/icons/chaticon.svg',
    'assets/icons/perfilicon.svg',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), 
          child: BottomNavigationBar(
            items: List.generate(5, (index) {
              List<String> labels = [
                'Explora',
                'Calendario',
                'Eventos',
                'Chat',
                'Perfil'
              ];

              bool isSelected = _selectedIndex == index;

              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: isSelected
                      ? ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: SvgPicture.asset(
                            _iconPaths[index],
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        )
                      : SvgPicture.asset(
                          _iconPaths[index],
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                        ),
                ),
                label: labels[index],
              );
            }),
             currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 24,
      selectedLabelStyle: TextStyle(
        height: 1.5,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Color(0xFFC20B0C),
              Color(0xFF7E0F9D),
              Color(0xFF2616C7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 20.0)),
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.black,
        height: 1.5,
          ),
        ),
      ),
    ),
    );
  }
}