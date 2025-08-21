import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/share_entrepreneurship_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/entrepreneurship/entrepreneurship_profile_page.dart';

// Modelos placeholder para datos faltantes
class Review {
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });
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
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      Review(
        userName: 'Carlos López',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        rating: 4,
        comment: 'Buen servicio y productos de calidad.',
        date: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];

    final exampleCollaborators = [
      Collaborator(
        name: 'Alejandra Guzmán',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      Collaborator(
        name: 'Gustavo Flores',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
      ),
      Collaborator(
        name: 'Elizabeth Camargo',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      Collaborator(
        name: 'Ana María',
        avatarUrl: 'https://i.pravatar.cc/150?img=6',
      ),
      Collaborator(
        name: 'Juana Larco',
        avatarUrl: 'https://i.pravatar.cc/150?img=7',
      ),
      Collaborator(
        name: 'Juan Benavides',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
      ),
    ];

    final Size screenSize = MediaQuery.of(context).size;
    const double designLogoDiameter = 114.0;
    const double designLogoRadius = designLogoDiameter / 2;
    const double designLogoTopPosition = 107.0;
    const double finalFlexibleBackgroundHeight =
        designLogoTopPosition + designLogoDiameter + 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<bool>(
                    future: _checkIsOwner(),
                    builder: (context, snapshot) {
                      final bool isOwner = snapshot.data == true;
                      return PopupMenuButton<String>(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EntrepreneurshipProfilePage(),
                              ),
                            );
                          } else if (value == 'share') {
                            _showShareModal(context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          final List<PopupMenuEntry<String>> items = [];
                          if (isOwner) {
                            items.add(
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
                            );
                          }
                          items.add(
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
                          );
                          return items;
                        },
                      );
                    },
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
                    height: finalFlexibleBackgroundHeight,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 174,
                      width: screenSize.width,
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
                    top: designLogoTopPosition,
                    left: 20,
                    child: Container(
                      width: designLogoDiameter,
                      height: designLogoDiameter,
                      decoration: ShapeDecoration(
                        color: Colors.grey[200],
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
                            color: Color(0xFFF9F9F9),
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

  // ===== MÉTODO MEJORADO PARA OBTENER ICONOS DE REDES SOCIALES =====
  Widget _getSocialIcon(String socialName) {
    String lowerName = socialName.toLowerCase();

    if (lowerName.contains("instagram")) {
      return Image.asset(
        'assets/icons/instagramicon.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.camera_alt, color: Color(0xFFE4405F), size: 24),
      );
    } else if (lowerName.contains("facebook")) {
      return Image.asset(
        'assets/icons/facebookicon.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24),
      );
    } else if (lowerName.contains("youtube")) {
      return Image.asset(
        'assets/icons/youtubeicon.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.play_circle_outline, color: Color(0xFFFF0000), size: 24),
      );
    } else if (lowerName.contains("tiktok")) {
      return Image.asset(
        'assets/icons/tiktokicon.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.music_note, color: Colors.black, size: 24),
      );
    } else {
      return Icon(Icons.link, color: Colors.grey[600], size: 24);
    }
  }

  // ===== MÉTODO MEJORADO PARA CONSTRUIR URLs =====
  String _buildSocialUrl(String socialName, String socialUrl) {
    String url = socialUrl.trim();
    String lowerName = socialName.toLowerCase();

    // Si ya es una URL completa, devolverla tal como está
    if (url.contains("http") || url.contains("www")) {
      return url;
    }

    // Remover @ si existe
    if (url.startsWith("@")) {
      url = url.substring(1);
    }

    // Construir URL según la plataforma
    if (lowerName.contains("instagram")) {
      return "https://www.instagram.com/$url";
    } else if (lowerName.contains("facebook")) {
      return "https://www.facebook.com/$url";
    } else if (lowerName.contains("youtube")) {
      if (!url.startsWith("@")) {
        return "https://www.youtube.com/@$url";
      }
      return "https://www.youtube.com/$url";
    } else if (lowerName.contains("tiktok")) {
      if (!url.startsWith("@")) {
        return "https://www.tiktok.com/@$url";
      }
      return "https://www.tiktok.com/$url";
    }

    return url; // Fallback
  }

  Widget _buildContent(
      BuildContext context,
      double exampleRating,
      int exampleTotalReviews,
      List<Review> exampleReviews,
      List<Collaborator> exampleCollaborators) {

    // Filtrar redes sociales excluyendo Twitch y Twitter
    final filteredSocials = entrepreneurship.socialDtos
        .where((social) => !social.name.toLowerCase().contains("twitch") &&
        !social.name.toLowerCase().contains("twitter"))
        .toList();

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
                  Flexible(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      entrepreneurship.entrepreneurshipName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.verified, color: Colors.blue, size: 20),
                ],
              ),
              SizedBox(height: 2),
              Text(
                "@${entrepreneurship.entrepreneursNickname}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 10),
              PillWidget(entrepreneurship.category),
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
        SizedBox(height: 8), // Espaciado consistente después del título
        if (entrepreneurship.socialDtos.where((social) => !social.name.toLowerCase().contains("twitch") &&
            !social.name.toLowerCase().contains("twitter")).isEmpty)
          Text("No hay redes sociales disponibles.",
              style: TextStyle(color: Colors.grey))
        else
          Column(
            children: entrepreneurship.socialDtos
                .where((social) => !social.name.toLowerCase().contains("twitch") &&
                !social.name.toLowerCase().contains("twitter"))
                .map((social) {
              Widget iconWidget;
              String url = social.socialUrl.trim();

              // Lógica para iconos usando assets personalizados
              if (social.name.toLowerCase().contains("instagram")) {
                iconWidget = Image.asset(
                  'assets/icons/instagramicon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.camera_alt, color: Color(0xFFE4405F), size: 20),
                );
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (url.startsWith("@")) {
                    url = url.substring(1);
                  }
                  url = "https://www.instagram.com/$url";
                }
              } else if (social.name.toLowerCase().contains("facebook")) {
                iconWidget = Image.asset(
                  'assets/icons/facebookicon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.facebook, color: Color(0xFF1877F2), size: 20),
                );
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (url.startsWith("@")) {
                    url = url.substring(1);
                  }
                  url = "https://www.facebook.com/$url";
                }
              } else if (social.name.toLowerCase().contains("youtube")) {
                iconWidget = Image.asset(
                  'assets/icons/youtubeicon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.play_circle_outline, color: Color(0xFFFF0000), size: 20),
                );
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (!url.startsWith("@")) {
                    url = "https://www.youtube.com/@$url";
                  }
                  url = "https://www.youtube.com/$url";
                }
              } else if (social.name.toLowerCase().contains("tiktok")) {
                iconWidget = Image.asset(
                  'assets/icons/tiktokicon.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.music_note, color: Colors.black, size: 20),
                );
                if (!(social.socialUrl.contains("http") ||
                    social.socialUrl.contains("www"))) {
                  if (!url.startsWith("@")) {
                    url = "https://www.tiktok.com/@$url";
                  }
                  url = "https://www.tiktok.com/$url";
                }
              } else {
                iconWidget = Icon(Icons.link, color: Colors.grey[600], size: 20);
              }

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(url));
                  },
                  child: Row(
                    children: [
                      iconWidget,
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          social.name.toLowerCase(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(Icons.open_in_new, size: 18, color: Colors.grey[600]),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 24),
        // Ubicación
        _buildSectionTitle(context, "Ubicación"),
        PillWidget(entrepreneurship.addressType),
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
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ))
              .toList(),
        SizedBox(height: 24),
        // Galería
        _buildSectionTitle(context, "Galería"),
        if (entrepreneurship.s3Files.isEmpty)
          Text("No hay imágenes en la galería.",
              style: TextStyle(color: Colors.grey))
        else
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: entrepreneurship.s3Files.length,
              itemBuilder: (context, index) {
                final file = entrepreneurship.s3Files[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      file.url,
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
                        child: Icon(Icons.broken_image, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 24),
        // Colaboraciones
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, "Colaboraciones"),
            TextButton(onPressed: () {}, child: Text("Ver más")),
          ],
        ),
        if (exampleCollaborators.isEmpty)
          Text("No hay colaboraciones para mostrar.",
              style: TextStyle(color: Colors.grey))
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exampleCollaborators.length > 4
                  ? 4
                  : exampleCollaborators.length,
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
        // Valoraciones
        _buildSectionTitle(context, "Valoraciones"),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              exampleRating.toStringAsFixed(1),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarRating(exampleRating),
                Text(
                  "$exampleTotalReviews comentarios",
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
            minimumSize: Size(double.infinity, 40),
          ),
        ),
        SizedBox(height: 16),
        if (exampleReviews.isEmpty)
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
                                  "${review.date.day}/${review.date.month}/${review.date.year}",
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
        SizedBox(height: 30),
      ],
    );
  }

  // Método para verificar si el usuario es el propietario del emprendimiento
  Future<bool> _checkIsOwner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;
      final uri = Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/self');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
          final dynamic id = data['id'];
          if (id is int) {
            return id == entrepreneurship.id;
          } else if (id is String) {
            final parsed = int.tryParse(id);
            if (parsed != null) {
              return parsed.toString() == entrepreneurship.id.toString();
            }
            return id.toString() == entrepreneurship.id.toString();
          } else if (id != null) {
            return id.toString() == entrepreneurship.id.toString();
          }
        }
      }
    } catch (_) {}
    return false;
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

  void _showShareModal(BuildContext context) {
    ShareEntrepreneurshipModal.show(
      context,
      entrepreneurshipId: entrepreneurship.id.toString(),
      entrepreneurshipName: entrepreneurship.entrepreneurshipName,
      summary: entrepreneurship.summary,
      imageUrl: entrepreneurship.entrepreneurLogo?.url,
    );
  }
}