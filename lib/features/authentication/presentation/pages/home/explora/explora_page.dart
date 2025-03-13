
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class ExploraPage extends StatefulWidget {
  const ExploraPage({super.key});

  @override
  _ExploraPageState createState() => _ExploraPageState();
}

class _ExploraPageState extends State<ExploraPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        preferredSize: Size.fromHeight(90),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0, bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: ' Buscar',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Icon(Icons.search),
                      ),
                      filled: true,
                      fillColor: Color(0xFFEDEFF1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(Icons.filter_list),
                  _buildCategoryButton('Todos', isActive: true),
                  _buildCategoryButton('Moda y Belleza'),
                  _buildCategoryButton('Viajes'),
                  _buildCategoryButton('Arte'),
                  _buildCategoryButton('Fitness'),
                ],
              ),
            ),
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: _tabController.index == 0
                          ? ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [Color(0xFFC20B0C), Color(0xFF7E0F9D), Color(0xFF2616C7)],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Influencers',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Text(
                              'Influencers',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ),
                    Tab(
                      child: _tabController.index == 1
                          ? ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [Color(0xFFC20B0C), Color(0xFF7E0F9D), Color(0xFF2616C7)],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Emprendimientos',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Text(
                              'Emprendimientos',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ),
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
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(left: _tabController.index * tabWidth),
                          width: tabWidth,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFC20B0C), Color(0xFF7E0F9D), Color(0xFF2616C7)],
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
                children: [
                  _buildNoResultsContent(),
                  _buildNoResultsContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoResultsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/noSearchResults.png',
            width: 160,
            height: 160,
          ),
          SizedBox(height: 16),
          Text(
            'Ups...',
            style: TextStyle(
              fontSize: 20,            
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No encontramos resultados que coincidan con tus criterios de búsqueda. Prueba con otros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: SvgPicture.asset(
          'assets/icons/filtericon.svg',
          width: 18,
          height: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.black : Colors.white,
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text),
      ),
    );
  }
}