import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/extended_event_model.dart';

class TabEventContentApplicators extends StatefulWidget {
  final ExtendedEvent extendedEvent;

  const TabEventContentApplicators({
    super.key,
    required this.extendedEvent,
  });

  @override
  State<TabEventContentApplicators> createState() => _TabEventContentApplicatorsState();
}

class _TabEventContentApplicatorsState extends State<TabEventContentApplicators> {
  late List<EventApplication> _pendingApplications;

  @override
  void initState() {
    super.initState();
    _pendingApplications = widget.extendedEvent.getPendingApplications();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay aplicaciones pendientes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Para el evento: ${widget.extendedEvent.event.eventName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de aplicaciones
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _pendingApplications.length,
            itemBuilder: (context, index) {
              final application = _pendingApplications[index];
              final influencer = application.influencer;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: influencer.influencerLogo?.url != null 
                        ? NetworkImage(influencer.influencerLogo?.url ?? '')
                        : null,
                    child: influencer.influencerLogo?.url == null
                        ? Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  title: Text(
                    influencer.influencerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  /*
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (influencer.alias != 'N/A') ...[
                        SizedBox(height: 4),
                        Text(
                          '@${influencer.alias}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  */
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Aceptar - con fondo negro
                      ElevatedButton(
                        onPressed: () {
                          _showAcceptDialog(application);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(90, 45),
                        ),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Botón Rechazar - con borde rojo
                      OutlinedButton(
                        onPressed: () {
                          _showRejectDialog(application);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFC13515),
                          side: BorderSide(color: Color(0xFFC13515), width: 1.5),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(90, 45),
                        ),
                        child: Text(
                          'Rechazar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog(EventApplication application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aceptar aplicación'),
          content: Text('¿Estás seguro de que quieres aceptar la aplicación de ${application.influencer.influencerName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptApplication(application);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(EventApplication application) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de advertencia
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                
                // Mensaje
                Text(
                  '¿Seguro de que quieres rechazar la aplicación de ${application.influencer.influencerName}?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(100, 60),
                        ),
                        child: Text(
                          'No, Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _rejectApplication(application);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC13515),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(100, 60),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sí, Rechazar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acceptApplication(EventApplication application) {
    // TODO: Implementar API call para aceptar aplicación
    print('Aceptando aplicación de ${application.influencer.influencerName} para evento ${widget.extendedEvent.event.eventName}');
    
    // Remover de la lista local temporalmente
    setState(() {
      _pendingApplications.remove(application);
    });
    
    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aplicación de ${application.influencer.influencerName} aceptada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectApplication(EventApplication application) {
    // TODO: Implementar API call para rechazar aplicación
    print('Rechazando aplicación de ${application.influencer.influencerName} para evento ${widget.extendedEvent.event.eventName}');
    
    // Remover de la lista local temporalmente
    setState(() {
      _pendingApplications.remove(application);
    });
    
    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aplicación de ${application.influencer.influencerName} rechazada'),
        backgroundColor: Colors.red,
      ),
    );
  }
}