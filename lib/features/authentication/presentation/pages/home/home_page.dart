import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/explora/explora_page.dart';

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
    Center(child: Text('Perfil')),
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
              List<IconData> icons = [
                Icons.explore,
                Icons.calendar_today,
                Icons.event,
                Icons.chat,
                Icons.person
              ];
              List<String> labels = [
                'Explora',
                'Calendario',
                'Eventos',
                'Chat',
                'Perfil'
              ];

              bool isSelected = _selectedIndex == index;

              return BottomNavigationBarItem(
                icon: isSelected
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
                        child: Icon(
                          icons[index],
                          color: Colors.white,
                        ),
                      )
                    : Icon(icons[index], color: Colors.black),
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
            selectedLabelStyle: TextStyle(
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
            unselectedLabelStyle: TextStyle(color: Colors.black),
          ),
        ),
      ),
     
    );
  }
}
