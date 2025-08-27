import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/extended_event_model.dart';

class TabEventContentAccepted extends StatefulWidget {
  final ExtendedEvent extendedEvent;

  const TabEventContentAccepted({
    super.key,
    required this.extendedEvent,
  });

  @override
  State<TabEventContentAccepted> createState() => _TabEventContentAcceptedState();
}

class _TabEventContentAcceptedState extends State<TabEventContentAccepted> {
  late List<EventApplication> _acceptedApplications;

  @override
  void initState() {
    super.initState();
    _acceptedApplications = widget.extendedEvent.getAcceptedApplications();
  }

  @override
  Widget build(BuildContext context) {
    if (_acceptedApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay colaboradores aceptados',
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
        // Header con contador
        Container(
          padding: EdgeInsets.all(16),
          /*
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Colaboradores Confirmados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_acceptedApplications.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          */
        ),
        
        // Lista de colaboradores aceptados
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _acceptedApplications.length,
            itemBuilder: (context, index) {
              final application = _acceptedApplications[index];
              final influencer = application.influencer;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
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
                  leading: Stack(
                    children: [
                      CircleAvatar(
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
                      // Badge de confirmado
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    influencer.influencerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
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
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'APROBADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de contacto
                      IconButton(
                        onPressed: () {
                          _showContactOptions(application);
                        },
                        icon: Icon(
                          Icons.message,
                          color: Colors.blue,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Botón de información
                      IconButton(
                        onPressed: () {
                          _showInfluencerDetails(application);
                        },
                        icon: Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          padding: EdgeInsets.all(8),
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

  void _showContactOptions(EventApplication application) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contactar a ${application.influencer.influencerName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text('Enviar Email'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar envío de email
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Función de email en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green),
                title: Text('Abrir Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Función de chat en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.orange),
                title: Text('Llamar'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar llamada
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Función de llamada en desarrollo')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfluencerDetails(EventApplication application) {
    final influencer = application.influencer;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
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
                // Avatar y nombre
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: influencer.influencerLogo?.url != null 
                      ? NetworkImage(influencer.influencerLogo?.url ?? '')
                      : null,
                  child: influencer.influencerLogo?.url == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
                SizedBox(height: 16),
                Text(
                  influencer.influencerName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (influencer.alias != 'N/A') ...[
                  SizedBox(height: 4),
                  Text(
                    '@${influencer.alias}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 20),
                
                // Información adicional
                if (influencer.description.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          influencer.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
