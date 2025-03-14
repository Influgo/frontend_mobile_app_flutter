import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Centro de ayuda',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          buildExpansionTile('Pregunta 1', 'Texto respondiendo a la pregunta 1.'),
          buildExpansionTile('Pregunta 2', 'Texto respondiendo a la pregunta 2.'),
          buildExpansionTile('Pregunta 3', 'Texto respondiendo a la pregunta 3.'),
          buildExpansionTile('Pregunta 4', 'Texto respondiendo a la pregunta 4.'),
          buildExpansionTile('Pregunta 5', 'Texto respondiendo a la pregunta 5.'),
        ],
      ),
    );
  }

  Widget buildExpansionTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero, // Evita doble padding
            childrenPadding: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
            title: Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
            ),
            trailing: const Icon(Icons.expand_more, color: Colors.black, size: 20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
