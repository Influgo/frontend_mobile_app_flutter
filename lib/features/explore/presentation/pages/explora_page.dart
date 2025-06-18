import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/tab_content_entrepreneurships.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/tab_content_influencers.dart';

class ExploraPage extends StatefulWidget {
  const ExploraPage({super.key});

  @override
  _ExploraPageState createState() => _ExploraPageState();
}

class _ExploraPageState extends State<ExploraPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final String _selectedCategory = "Todos";

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Buscar perfil',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.search, size: 20),
                        ),
                        filled: true,
                        fillColor: Color(0xFFEDEFF1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {},
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
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
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
                Transform.translate(
                  offset: Offset(0, -12.0),
                  child: Stack(
                    children: [
                      Container(
                        height: 2,
                        color: Colors.grey[300],
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double tabWidth = constraints.maxWidth / 2;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.only(
                                left: _tabController.index * tabWidth),
                            width: tabWidth,
                            height: 2,
                            decoration: BoxDecoration(
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
