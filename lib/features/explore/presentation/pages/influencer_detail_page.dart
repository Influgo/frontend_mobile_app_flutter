import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

// Modelos placeholder para datos faltantes (similares a ExploraDetailPage)
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

class Socials {
  final String userName;
  final String socialName;
  final int followers;
  final String ranking; // Puede ser número con K/M o texto como "2.5k"
  final String? engagementMetric; // "Me gustas", "Visualizaciones", "Transmisión"
  final String? engagementValue; // "15M", "2.5k", etc.
  final String? profileUrl; // URL completa del perfil
  final String? iconAsset; // Ruta del ícono de la red social
  final List<Color>? brandColors; // Colores de la marca para gradientes

  Socials({
    required this.userName,
    required this.socialName,
    required this.followers,
    required this.ranking,
    this.engagementMetric,
    this.engagementValue,
    this.profileUrl,
    this.iconAsset,
    this.brandColors,
  });
}

class InfluencerDetailPage extends StatelessWidget {
  final Influencer influencer;

  const InfluencerDetailPage({super.key, required this.influencer});

  String _formatFollowersCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }


  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para secciones faltantes
    final exampleRating = influencer.rating;
    final exampleTotalReviews = 76;
    final exampleReviews = [
      Review(
        userName: 'Ana María',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
        rating: 5,
        comment: 'Excelente trabajo con ${influencer.influencerName}, muy profesional.',
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      Review(
        userName: 'Carlos López',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        rating: 4,
        comment: 'Gran contenido y muy buena comunicación.',
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

    // Datos de ejemplo para redes sociales mejorados
    final exampleSocials = [
      Socials(
        userName: '@ana27_maria',
        socialName: 'Instagram',
        followers: 2500,
        ranking: '2.5k',
        engagementMetric: 'Seguidores',
        engagementValue: '2.5k',
      ),
      Socials(
        userName: '@ana27_maria',
        socialName: 'TikTok',
        followers: 10050,
        ranking: '1M',
        engagementMetric: 'Me gustas',
        engagementValue: '1M',
      ),
      Socials(
        userName: '@ana27_maria',
        socialName: 'YouTube',
        followers: 2500,
        ranking: '2.5k',
        engagementMetric: 'Visualizaciones',
        engagementValue: '2.5k',
      ),
      Socials(
        userName: '@ana27_maria',
        socialName: 'Twitch',
        followers: 2500,
        ranking: '2.5k',
        engagementMetric: 'Transmisión',
        engagementValue: '2.5k',
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
            backgroundColor: Color(0xFFF9F9F9).withOpacity(0.8),
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
                    height: finalFlexibleBackgroundHeight,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 174,
                      width: screenSize.width,
                      child: influencer.influencerBanner != null
                          ? Image.network(
                              influencer.influencerBanner!.url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purple.shade300,
                                        Colors.pink.shade300,
                                        Colors.orange.shade300,
                                      ],
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.purple.shade300,
                                      Colors.pink.shade300,
                                      Colors.orange.shade300,
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.purple.shade300,
                                    Colors.pink.shade300,
                                    Colors.orange.shade300,
                                  ],
                                ),
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
                        image: influencer.influencerProfileImage?.url != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    influencer.influencerProfileImage!.url),
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
                      child: influencer.influencerProfileImage?.url == null
                          ? Icon(Icons.person,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildContent(
                context,
                exampleRating,
                exampleTotalReviews,
                exampleReviews,
                exampleCollaborators,
                exampleSocials,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlassSocialIcon({
    required List<Color> gradientColors,
    required String assetPath,
    double size = 40,
  }) {
    final gradient = LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                assetPath,
                width: size * 0.5,
                height: size * 0.5,
                color: Colors.white,
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
    
    // Definir colores y iconos según la red social
    List<Color> gradientColors;
    Widget iconWidget;
    
    if (lowerName.contains("instagram")) {
      gradientColors = [
        Color(0xFFF58529), // Naranja
        Color(0xFFDD2A7B), // Rosa
        Color(0xFF8134AF), // Morado
        Color(0xFF515BD4), // Azul
      ];
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Image.asset(
          'assets/icons/instagramicon.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      );
      final instagramExample = Socials(
        userName: '@ana27_maria',
        socialName: 'Instagram',
        followers: 2500,
        ranking: '2.5k',
        engagementMetric: 'Seguidores',
        engagementValue: '2.5k',
      );
    } else if (lowerName.contains("tiktok")) {
      gradientColors = [
        Color(0xFF00F2EA), // Turquesa
        Color(0xFFEE1D52), // Rosa
      ];
    iconWidget = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Image.asset(
          'assets/icons/tiktokicon.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      );
      final tiktokExample = Socials(
        userName: '@tiktok_user',
        socialName: 'TikTok',
        followers: 1500,
        ranking: '1.5k',
        engagementMetric: 'Seguidores',
        engagementValue: '1.5k',
      );
    } else if (lowerName.contains("youtube")) {
      gradientColors = [
        Color(0xFFFF0000), // Rojo YouTube
        Color(0xFF282828), // Rojo más claro
      ];
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Image.asset(
          'assets/icons/youtubeicon.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      );
      final youtubeExample = Socials(
        userName: '@youtube_user',
        socialName: 'YouTube',
        followers: 5000,
        ranking: '5k',
        engagementMetric: 'Visualizaciones',
        engagementValue: '5k',
      );
    } else if (lowerName.contains("twitch")) {
      gradientColors = [
        Color(0xFF9146FF), // Morado Twitch
        Color(0xFFB877FF), // Morado más claro
      ];
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Image.asset(
          'assets/icons/twitchicon.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      );
      final twitchExample = Socials(
        userName: '@twitch_user',
        socialName: 'Twitch',
        followers: 3000,
        ranking: '3k',
        engagementMetric: 'Transmisión',
        engagementValue: '3k',
      );
    } else if (lowerName.contains("facebook")) {
      gradientColors = [
        Color(0xFF1877F2), // Azul Facebook
        Color(0xFF42A5F5), // Azul más claro
      ];
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Image.asset(
          'assets/icons/facebookicon.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      );
    } else {
      gradientColors = [
        Colors.grey.shade400,
        Colors.grey.shade600,
      ];
      iconWidget = Icon(Icons.link, color: Colors.white, size: 18);
    }

    return Container(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none, // Permite que el contenido rotado sobresalga
        children: [
          // Fondo con rotación (sin recorte) - posicionado un poco más abajo
          Positioned(
            top: 4, // Mover la capa rotada 2 píxeles hacia abajo
            left: 5,
            child: Transform.rotate(
              angle: 15 * 3.14159 / 180, // 30 grados en radianes
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          // Segunda capa con border radius
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white, // Capa blanca sólida como base
              ),
            ),
          ),
          // Tercera capa con gradiente suave
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors.map((color) => color.withOpacity(0.4)).toList(),
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          // Capa de filtro blur
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
          // Logo centrado al frente
          Center(child: iconWidget),
        ],
      ),
    );
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

  // ===== MÉTODO PARA OBTENER COLORES DE DEGRADADO POR RED SOCIAL =====
  List<Color> _getSocialGradientColors(String socialName) {
    String lowerName = socialName.toLowerCase();
    
    if (lowerName.contains("instagram")) {
      return [
        Color(0xFFF58529), // Naranja
        Color(0xFFDD2A7B), // Rosa
        Color(0xFF8134AF), // Morado
        Color(0xFF515BD4), // Azul
      ];
    } else if (lowerName.contains("tiktok")) {
      return [
        Color(0xFF00F2EA), // Turquesa
        Color(0xFFEE1D52), // Rosa
      ];
    } else if (lowerName.contains("youtube")) {
      return [
        Color(0xFFFF0000), // Rojo YouTube
        Color(0xFF282828), // Rojo más oscuro
      ];
    } else if (lowerName.contains("twitch")) {
      return [
        Color(0xFF9146FF), // Morado Twitch
        Color(0xFFB877FF), // Morado más claro
      ];
    } else if (lowerName.contains("facebook")) {
      return [
        Color(0xFF1877F2), // Azul Facebook
        Color(0xFF42A5F5), // Azul más claro
      ];
    } else {
      return [
        Colors.grey.shade400,
        Colors.grey.shade600,
      ];
    }
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w100, color: Colors.black54, fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocials(BuildContext context, List<Socials> socials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: socials.map((social) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatColumn(
                    social.userName,
                    social.socialName
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildStatColumn(
                      social.ranking,
                      "Seguidores",
                    ),
                  ),
                  Flexible(
                    child: _buildStatColumn(
                      social.engagementValue ?? '',
                      social.engagementMetric ?? '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContent(
      BuildContext context,
      double exampleRating,
      int exampleTotalReviews,
      List<Review> exampleReviews,
      List<Collaborator> exampleCollaborators,
      List<Socials> exampleSocials) {
    
    // Filtrar redes sociales excluyendo Twitter y Facebook
    final filteredSocials = influencer.socialDtos
        .where((social) => !social.name.toLowerCase().contains("twitter") 
                          && !social.name.toLowerCase().contains("facebook"))
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
                      influencer.influencerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                    ),
                  ),
                  if (influencer.isVerified) ...[
                    SizedBox(width: 8),
                    Icon(Icons.verified, color: Colors.blue, size: 24),
                  ],
                ],
              ),
              SizedBox(height: 4),
              Text(
                influencer.influencerHandle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
              SizedBox(height: 8),
              PillWidget(influencer.category),
            ],
          ),
        ),
        SizedBox(height: 16),
        
        // Summary del influencer
        Text(
          influencer.summary,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        
        SizedBox(height: 24),
        
        // Redes sociales
        _buildSectionTitle(context, "Redes Sociales"),
        SizedBox(height: 8),
        if (filteredSocials.isEmpty)
          Text("No hay redes sociales disponibles.",
              style: TextStyle(color: Colors.grey))
        else
          Column(
            children: filteredSocials.map((social) {
              String url = _buildSocialUrl(social.name, social.socialUrl);

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: _getSocialGradientColors(social.name),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.white.withOpacity(0.91),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            launchUrl(Uri.parse(url));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            child: Row(
                              children: [
                                _getSocialIcon(social.name),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildSocials(context, exampleSocials.where((mockSocial) => 
                                    mockSocial.socialName.toLowerCase() == social.name.toLowerCase()).toList()),
                                ),
                                //Icon(Icons.open_in_new, size: 18, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 24),
        
        // Descripción
        _buildSectionTitle(context, "Descripción"),
        Text(
          influencer.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 24),
        
        // Especialidades
        if (influencer.specialties.isNotEmpty) ...[
          _buildSectionTitle(context, "Especialidades"),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: influencer.specialties
                .map((specialty) => Chip(
                      label: Text(specialty),
                      backgroundColor: Colors.grey.shade100,
                    ))
                .toList(),
          ),
          SizedBox(height: 24),
        ],

        // Ubicación
        _buildSectionTitle(context, "Ubicación"),
        if (influencer.addresses.isEmpty)
          Text("No hay ubicación disponible.",
              style: TextStyle(color: Colors.grey))
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: influencer.addresses
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
          ),
        SizedBox(height: 24),

        // Galería
        _buildSectionTitle(context, "Galería"),
        if (influencer.portfolioFiles.isEmpty)
          Text("No hay imágenes en el portafolio.",
              style: TextStyle(color: Colors.grey))
        else
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: influencer.portfolioFiles.length,
              itemBuilder: (context, index) {
                final file = influencer.portfolioFiles[index];
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
    // TODO: Implementar modal de compartir para influencers
    // Similar a ShareEntrepreneurshipModal pero para influencers
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartir perfil de ${influencer.influencerName}')),
    );
  }
}
