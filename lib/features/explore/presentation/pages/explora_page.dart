import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/tab_content_entrepreneurships.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/tab_content_influencers.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_page.dart'; // ← NUEVA IMPORTACIÓN

class ExploraPage extends StatefulWidget {
  const ExploraPage({super.key});

  @override
  _ExploraPageState createState() => _ExploraPageState();
}

class _ExploraPageState extends State<ExploraPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedCategory = "Todos";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ← NUEVA FUNCIÓN PARA ABRIR LA BÚSQUEDA
  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      // ← CAMBIO: Hacer que toda la caja sea clickeable
                      onTap: _openSearchPage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEFF1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          enabled:
                              false, // ← CAMBIO: Deshabilitar edición directa
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Buscar perfil',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(Icons.search, size: 20),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEDEFF1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              // ← CAMBIO: Estilo cuando está deshabilitado
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Aquí puedes añadir funcionalidad para notificaciones
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: SvgPicture.asset(
                        'assets/icons/notificationsicon.svg',
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    CustomTabItem(
                        title: 'Influencers',
                        index: 0,
                        tabController: _tabController),
                    CustomTabItem(
                        title: 'Emprendimientos',
                        index: 1,
                        tabController: _tabController),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      height: 2,
                      color: Colors.grey[300],
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double tabWidth = constraints.maxWidth / 2;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(
                              left: _tabController.index * tabWidth),
                          width: tabWidth,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TabContentInfluencers(),
                  TabContentEntrepreneurships(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
