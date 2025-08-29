import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/pages/explora_page.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/pages/events_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/modals/account_under_review_modal.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/modals/complete_profile_modal.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/influencer/influencer_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/entrepreneurship/entrepreneurship_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/pages/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _accountStatus;
  bool _isLoadingAccountStatus = true;
  bool? _profileCompleted;
  String? _userRole;

  static List<Widget> _pages = <Widget>[
    ExploraPage(),
    Center(child: Text('Calendario')), // Will be replaced dynamically
    EventsPage(),
    Center(child: Text('Chat')),
    ProfileScreen(),
  ];

  final List<String> _iconPaths = [
    'assets/icons/exploraicon.svg',
    'assets/icons/calendarioicon.svg',
    'assets/icons/eventosicon.svg',
    'assets/icons/chaticon.svg',
    'assets/icons/perfilicon.svg',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccountStatus();
  }

  Future<void> _loadAccountStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('token');

      if (userId == null || token == null) {
        setState(() {
          _isLoadingAccountStatus = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/account/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final accountStatus = data['userDto']?['accountStatus'];
        final profileCompleted = data['profileCompleted'];
        final roles = data['userDto']?['roles'] as List<dynamic>?;
        
        // Extraer el rol del usuario
        String? userRole;
        if (roles != null && roles.isNotEmpty) {
          userRole = roles.first['roles']?['name'];
        }
        
        setState(() {
          _accountStatus = accountStatus;
          _profileCompleted = profileCompleted;
          _userRole = userRole;
          _isLoadingAccountStatus = false;
          // Update pages dynamically based on account status
          if (_accountStatus?.toUpperCase() == 'ACTIVE') {
            _pages[1] = CalendarPage();
          } else {
            _pages[1] = Center(child: Text('Calendario'));
          }
        });
      } else {
        setState(() {
          _isLoadingAccountStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar estado de cuenta: $e');
      setState(() {
        _isLoadingAccountStatus = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Validación específica para Calendario (index 1) y Chat (index 3)
    if (index == 1 || index == 3) {
      // Primera validación: Account Status
      if (_accountStatus?.toUpperCase() == 'PENDING_VERIFICATION') {
        Future.delayed(Duration(milliseconds: 300), () {
          _showAccountUnderReviewModal();
        });
        return;
      }
      
      // Segunda validación: Profile Completed (solo para Chat)
      if (index == 3 && _accountStatus?.toUpperCase() == 'ACTIVE' && _profileCompleted == false) {
        Future.delayed(Duration(milliseconds: 300), () {
          _showCompleteProfileModal();
        });
        return;
      }
    }
  }

  void _showAccountUnderReviewModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AccountUnderReviewModal(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showCompleteProfileModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CompleteProfileModal(
          userRole: _userRole ?? 'INFLUENCER',
          onClose: () {
            Navigator.of(context).pop();
          },
          onCompleteProfile: () {
            Navigator.of(context).pop();
            _navigateToProfile();
          },
        );
      },
    );
  }

  void _navigateToProfile() {
    // Navegar directamente a la página de creación de perfil según el rol
    if (_userRole?.toUpperCase() == 'INFLUENCER') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InfluencerProfilePage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EntrepreneurshipProfilePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingAccountStatus 
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: _pages
            ),
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
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        )
                      : SvgPicture.asset(
                          _iconPaths[index],
                          width: 24,
                          height: 24,
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
