import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/share_entrepreneurship_modal.dart'; // ← NUEVO IMPORT

// Modelos placeholder para datos faltantes
class Review {
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  Review(
      {required this.userName,
      required this.userAvatarUrl,
      required this.rating,
      required this.comment,
      required this.date});
}

class Collaborator {
  final String name;
  final String avatarUrl;
  Collaborator({required this.name, required this.avatarUrl});
}

class ExploraDetailPage extends StatelessWidget {
  final Entrepreneurship entrepreneurship;

  const ExploraDetailPage({super.key, required this.entrepreneurship});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para secciones faltantes
    final exampleRating = 4.5;
    final exampleTotalReviews = 76;
    final exampleReviews = [
      Review(
          userName: 'Ana María',
          userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
          rating: 5,
          comment: 'Trabajar con Las Canastas fue una experiencia increíble.',
          date: DateTime.now().subtract(Duration(days: 2))),
      Review(
          userName: 'Carlos López',
          userAvatarUrl: 'https://i.pravatar.cc/150?img=2',
          rating: 4,
          comment: 'Buen servicio y productos de calidad.',
          date: DateTime.now().subtract(Duration(days: 5))),
    ];
    final exampleCollaborators = [
      Collaborator(
          name: 'Alejandra Guzmán',
          avatarUrl: 'https://i.pravatar.cc/150?img=3'),
      Collaborator(
          name: 'Gustavo Flores', avatarUrl: 'https://i.pravatar.cc/150?img=4'),
      Collaborator(
          name: 'Elizabeth Camargo',
          avatarUrl: 'https://i.pravatar.cc/150?img=5'),
      Collaborator(
          name: 'Ana María', avatarUrl: 'https://i.pravatar.cc/150?img=6'),
      Collaborator(
          name: 'Juana Larco', avatarUrl: 'https://i.pravatar.cc/150?img=7'),
      Collaborator(
          name: 'Juan Benavides', avatarUrl: 'https://i.pravatar.cc/150?img=8'),
    ];

    final Size screenSize =
        MediaQuery.of(context).size; // Obtener el tamaño de la pantalla

    const double designLogoDiameter = 114.0;
    const double designLogoRadius = designLogoDiameter / 2;
    const double designLogoTopPosition = 107.0;
    const double finalFlexibleBackgroundHeight =
        designLogoTopPosition + designLogoDiameter + 10;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            clipBehavior: Clip.none,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.arrow_back_ios,
                        color: Colors.black, size: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              // ===== BOTÓN DE MÁS OPCIONES CON MENÚ =====
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.black, size: 20),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 8,
                    onSelected: (String value) {
                      if (value == 'edit') {
                        // TODO: Implementar editar perfil
                      } else if (value == 'share') {
                        _showShareModal(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                color: Colors.black, size: 20),
                            SizedBox(width: 12),
                            Text('Editar Perfil',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined,
                                color: Colors.black, size: 20),
                            SizedBox(width: 12),
                            Text('Compartir Perfil',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height:
                        finalFlexibleBackgroundHeight, // Debe coincidir con expandedHeight
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      // Esta es la altura real de tu imagen de banner
                      height: 174, // 174.0px
                      width: screenSize
                          .width, // Opcional si Positioned ya tiene left y right
                      child: Image.network(
                        entrepreneurship.entrepreneurBanner?.url ??
                            'https://via.placeholder.com/393x174.png?text=Banner',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.broken_image, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top:
                        designLogoTopPosition, // 107.0px desde el top del SizedBox principal
                    left: 20,
                    child: Container(
                      width: designLogoDiameter, // 114.0px
                      height: designLogoDiameter,
                      decoration: ShapeDecoration(
                        color: Colors.grey[200], // Placeholder
                        image: entrepreneurship.entrepreneurLogo?.url != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    entrepreneurship.entrepreneurLogo!.url),
                                fit: BoxFit.cover,
                              )
                            : null,
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 4,
                            color: Color(
                                0xFFF9F9F9), // Borde blanco como en tu diseño
                          ),
                        ),
                      ),
                      child: entrepreneurship.entrepreneurLogo?.url == null
                          ? Icon(Icons.business,
                              size: designLogoRadius * 0.8,
                              color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildContent(
                context,
                exampleRating,
                exampleTotalReviews,
                exampleReviews,
                exampleCollaborators,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      double exampleRating,
      int exampleTotalReviews,
      List<Review> exampleReviews,
      List<Collaborator> exampleCollaborators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Nombre y Categoría
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      entrepreneurship.entrepreneurshipName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 20, // ← Aumentado de ~14 a 16
                          ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.verified,
                      color: Colors.blue, size: 24), // ← Aumentado de 20 a 22
                ],
              ),
              SizedBox(height: 4),
              Text(
                "@${entrepreneurship.entrepreneursNickname}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // ← Aumentado de ~11 a 13
                    ),
              ),
              /*SizedBox(height: 8),
              Text(
                "@${entrepreneurship.entrepreneursNickname}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13, // ← Aumentado de ~11 a 13
                    ),
              ),*/
              SizedBox(height: 8),
              PillWidget(entrepreneurship.category),

              // Chip(
              //   label: Text(entrepreneurship.category),
              //   backgroundColor: Colors.orange.shade100,
              //   labelStyle: TextStyle(
              //       color: Colors.orange.shade800, fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
        SizedBox(height: 16),

        Text(
          entrepreneurship.summary,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),

        // Descripción
        _buildSectionTitle(context, "Descripción"),
        Text(
          entrepreneurship.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 24),

        // Redes
        _buildSectionTitle(context, "Redes"),
        if (entrepreneurship.socialDtos.isEmpty)
          Text("No hay redes sociales disponibles.",
              style: TextStyle(color: Colors.grey))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: entrepreneurship.socialDtos.length,
            itemBuilder: (context, index) {
              final social = entrepreneurship.socialDtos[index];
              IconData iconData;
              String url = social.socialUrl.trim();
              // Lógica simple para iconos (puede mejorarse)
              if (social.name.toLowerCase().contains("instagram")) {
                iconData = Icons
                    .camera_alt_outlined; // Deberías tener un mapeo mejor o usar FontAwesomeIcons
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (url.startsWith("@")) {
                    url = url.substring(1);
                  }
                  url = "https://www.instagram.com/$url";
                }
              } else if (social.name.toLowerCase().contains("twitch")) {
                iconData = Icons.facebook;
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (url.startsWith("@")) {
                    url = url.substring(1);
                  }
                  url = "https://www.twitch.tv/$url";
                }

                // } else if (social.name.toLowerCase().contains("facebook")) {
                //   iconData = Icons.facebook;
                // } else if (social.name.toLowerCase().contains("twitter")) {
                //   iconData = Icons.flutter_dash; // Placeholder
              } else if (social.name.toLowerCase().contains("youtube")) {
                iconData = Icons.play_circle_outline;

                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (!url.startsWith("@")) {
                    url = "https://www.youtube.com/@$url";
                  }
                  url = "https://www.youtube.com/$url";
                }
              } else if (social.name.toLowerCase().contains("tiktok")) {
                iconData = Icons.music_note_outlined;
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (!url.startsWith("@")) {
                    url = "https://www.tiktok.com/@$url";
                  }
                  url = "https://www.tiktok.com/$url";
                }
              } else {
                iconData = Icons.link;
              }

              return Padding(
                  // padding: const EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : 4,
                    // bottom: 4,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse(url));
                    },
                    child: Row(
                      children: [
                        Icon(iconData, color: Colors.black),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text(
                          social.name,
                          style: TextStyle(color: Colors.black),
                        )),
                        Icon(Icons.open_in_new, size: 20, color: Colors.black),
                      ],
                    ),
                  ));
            },
          ),
        SizedBox(height: 24),

        // Ubicación
        _buildSectionTitle(context, "Ubicación"),
        PillWidget(entrepreneurship.addressType),
        // Chip(
        //   label: Text(entrepreneurship.addressType), // Ej: "Presencial"
        //   backgroundColor:
        //       entrepreneurship.addressType.toLowerCase() == "presencial"
        //           ? Colors.blue.shade100
        //           : Colors.green.shade100,
        //   labelStyle: TextStyle(
        //       color: entrepreneurship.addressType.toLowerCase() == "presencial"
        //           ? Colors.blue.shade800
        //           : Colors.green.shade800,
        //       fontWeight: FontWeight.bold),
        // ),
        SizedBox(height: 8),
        if (entrepreneurship.addresses.isEmpty)
          Text("No hay direcciones disponibles.",
              style: TextStyle(color: Colors.grey))
        else
          ...entrepreneurship.addresses
              .map((address) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(address,
                                style: Theme.of(context).textTheme.bodyLarge)),
                      ],
                    ),
                  ))
              .toList(),
        SizedBox(height: 24),

        // Enfoque
        _buildSectionTitle(context, "Enfoque"),
        if (entrepreneurship.entrepreneurFocus.isEmpty)
          Text("No hay enfoques definidos.",
              style: TextStyle(color: Colors.grey))
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: entrepreneurship.entrepreneurFocus
                .map((focus) => Chip(label: Text(focus)))
                .toList(),
          ),
        SizedBox(height: 24),

        // Galería
        _buildSectionTitle(context, "Galería"),
        if (entrepreneurship.s3Files.isEmpty)
          Text("No hay imágenes en la galería.",
              style: TextStyle(color: Colors.grey))
        else
          Container(
            height: 120, // Altura de la galería horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: entrepreneurship.s3Files.length,
              itemBuilder: (context, index) {
                final file = entrepreneurship.s3Files[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(file.url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[600]))),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 24),

        // Colaboraciones (NECESITA DATOS DEL MODELO)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, "Colaboraciones"),
            TextButton(onPressed: () {}, child: Text("Ver más")),
          ],
        ),
        if (exampleCollaborators
            .isEmpty) // Usa entrepreneurship.collaborators cuando lo tengas
          Text("No hay colaboraciones para mostrar.",
              style: TextStyle(color: Colors.grey))
        else
          SizedBox(
            height: 100, // Altura para la lista de colaboradores
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exampleCollaborators.length > 4
                  ? 4
                  : exampleCollaborators
                      .length, // Mostrar solo algunos inicialmente
              itemBuilder: (context, index) {
                final collaborator = exampleCollaborators[index];
                return Container(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(collaborator.avatarUrl),
                      ),
                      SizedBox(height: 4),
                      Text(
                        collaborator.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 24),

        // Valoraciones (NECESITA DATOS DEL MODELO)
        _buildSectionTitle(context,
            "Valoraciones"), // En la imagen dice "Descripción", pero "Valoraciones" es más apropiado
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              exampleRating
                  .toStringAsFixed(1), // Usa entrepreneurship.averageRating
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarRating(
                    exampleRating), // Usa entrepreneurship.averageRating
                Text(
                  "$exampleTotalReviews comentarios", // Usa entrepreneurship.totalReviews
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.edit_outlined, size: 18),
          label: Text("Escribe un comentario"),
          onPressed: () {
            // Lógica para escribir comentario
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 40), // Ancho completo
          ),
        ),
        SizedBox(height: 16),
        if (exampleReviews.isEmpty) // Usa entrepreneurship.reviews
          Text("Aún no hay comentarios.", style: TextStyle(color: Colors.grey))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: exampleReviews.length,
            itemBuilder: (context, index) {
              final review = exampleReviews[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(review.userAvatarUrl),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review.userName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  "${review.date.day}/${review.date.month}/${review.date.year}", // Formatea la fecha como necesites
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          _buildStarRating(review.rating, itemSize: 16),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(review.comment),
                    ],
                  ),
                ),
              );
            },
          ),
        SizedBox(height: 30), // Espacio al final
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStarRating(double rating, {double itemSize = 20}) {
    // Implementación simple de estrellas. Puedes usar flutter_rating_bar para más opciones.
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: itemSize));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: itemSize));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: itemSize));
      }
    }
    return Row(children: stars);
  }

  // ===== MÉTODO PARA MOSTRAR EL MODAL DE COMPARTIR =====
  void _showShareModal(BuildContext context) {
    ShareEntrepreneurshipModal.show(
      context,
      entrepreneurshipId: entrepreneurship.id?.toString() ?? 'unknown',
      entrepreneurshipName: entrepreneurship.entrepreneurshipName,
      summary: entrepreneurship.summary,
      imageUrl: entrepreneurship.entrepreneurLogo?.url,
    );
  }
}
