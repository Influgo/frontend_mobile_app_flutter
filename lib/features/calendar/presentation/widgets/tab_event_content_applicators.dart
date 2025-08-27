import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/extended_event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/contract_entrepreneurship_screen.dart';

class TabEventContentApplicators extends StatefulWidget {
  final ExtendedEvent extendedEvent;
  final VoidCallback? onContractSigned;

  const TabEventContentApplicators({
    super.key,
    required this.extendedEvent,
    this.onContractSigned,
  });

  @override
  State<TabEventContentApplicators> createState() => _TabEventContentApplicatorsState();
}

class _TabEventContentApplicatorsState extends State<TabEventContentApplicators> {
  late List<EventApplication> _pendingApplications;
  final Set<int> _acceptedApplicationIds = <int>{}; // Track accepted applications

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
                      // Botón Aceptar/Firmar - con fondo dinámico
                      ElevatedButton(
                        onPressed: () {
                          final isAccepted = _acceptedApplicationIds.contains(application.influencer.id);
                          if (isAccepted) {
                            _navigateToContract(application);
                          } else {
                            _showAcceptDialog(application);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _acceptedApplicationIds.contains(application.influencer.id) 
                              ? Color(0xFF006BD6) 
                              : Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(90, 45),
                        ),
                        child: Text(
                          _acceptedApplicationIds.contains(application.influencer.id) ? 'Firmar' : 'Aceptar',
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
                    color: Color(0xFFF2C94C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/alerticon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Precaución
                Text(
                  '¿Seguro que deseas aceptar la aplicación de ${application.influencer.influencerName}?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Mensaje
                Text(
                  'Luego tendrás que firmar un contrato, para oficializar su participación en tu evento.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
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
                          'No, cancelar',
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
                          _acceptApplication(application);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(100, 60),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sí, continuar',
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/rejecticon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Mensaje
                Text(
                  '¿Seguro de que quieres rechazar la aplicación de ${application.influencer.influencerName}?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
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
                          'No, cancelar',
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
                          'Sí, rechazar',
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
    // Solo marcar como aceptada localmente, NO cambiar el estado aún
    print('Aceptando aplicación de ${application.influencer.influencerName} para evento ${widget.extendedEvent.event.eventName}');
    print('Estado actual del influencer: ${application.status}');
    print('ID del influencer: ${application.influencer.id}');
    
    // Marcar como aceptada pero mantener en la lista para mostrar botón de firmar
    setState(() {
      _acceptedApplicationIds.add(application.influencer.id);
    });
    
    print('Estado después de aceptar - IDs aceptados: $_acceptedApplicationIds');
    print('¿Está en la lista de aceptados? ${_acceptedApplicationIds.contains(application.influencer.id)}');
    print('� El estado permanece PENDING hasta firmar el contrato');
    
    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aplicación de ${application.influencer.influencerName} aceptada. Ahora puedes firmar el contrato.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToContract(EventApplication application) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractEntrepreneurshipScreen(
          application: application,
          eventName: widget.extendedEvent.event.eventName,
          onContractSigned: widget.onContractSigned,
        ),
      ),
    );

    // Si se firmó el contrato, AHORA SÍ cambiar el estado a APPROVED en el backend
    if (result == true) {
      print('🎉 Contrato firmado! Llamando al backend para cambiar estado a APPROVED...');
      
      // Cambiar el estado de PENDING a APPROVED (llamada al backend)
      bool success = await widget.extendedEvent.approveApplication(application.influencer.id);
      
      if (success) {
        setState(() {
          // Actualizar la lista local de aplicaciones pendientes
          _pendingApplications = widget.extendedEvent.getPendingApplications();
          _acceptedApplicationIds.remove(application.influencer.id);
        });
        
        print('✅ Estado cambiado exitosamente a APPROVED en el backend');
        print('📊 El influencer ahora aparece en Participantes');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contrato firmado con ${application.influencer.influencerName}. Ahora aparece en "Participantes".'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('❌ Error al cambiar estado a APPROVED en el backend');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el contrato. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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