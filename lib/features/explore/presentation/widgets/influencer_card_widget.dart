import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/pages/influencer_detail_page.dart';

class InfluencerCardWidget extends StatelessWidget {
  final Influencer influencer;

  const InfluencerCardWidget({
    super.key,
    required this.influencer,
  });

  String _formatFollowersCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildSocialNetworksRow() {
    // Filtrar solo las redes sociales que tiene el influencer (máximo 2 para tarjetas)
    List<Widget> socialIcons = [];
    
    for (SocialDto social in influencer.socialDtosForCards) {
      Widget? iconWidget = _getSocialIcon(social.name);
      if (iconWidget != null) {
        socialIcons.add(_buildSocialContainer(iconWidget, social));
      }
    }

    // Si no tiene redes sociales, no mostrar nada
    if (socialIcons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialIcons
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .take(socialIcons.length * 2 - 1) // Quitar el último SizedBox
          .toList(),
    );
  }

  Widget? _getSocialIcon(String socialName) {
    String socialLower = socialName.toLowerCase();
    
    if (socialLower.contains('instagram')) {
      return Image.asset(
        'assets/icons/instagramicon.png',
        width: 12,
        height: 12,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.camera_alt, color: Color(0xFFE4405F), size: 12),
      );
    } else if (socialLower.contains('tiktok')) {
      return Image.asset(
        'assets/icons/tiktokicon.png',
        width: 12,
        height: 12,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.music_note, color: Colors.black, size: 12),
      );
    } else if (socialLower.contains('youtube')) {
      return Image.asset(
        'assets/icons/youtubeicon.png',
        width: 12,
        height: 12,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.play_circle_outline, color: Color(0xFFFF0000), size: 12),
      );
    } else if (socialLower.contains('twitch')) {
      return Image.asset(
        'assets/icons/twitchicon.png',
        width: 12,
        height: 12,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.videogame_asset, color: Color(0xFF9146FF), size: 12),
      );
    }
    
    // Si no es una red social reconocida, no mostrar icono
    return null;
  }

  Widget _buildSocialContainer(Widget iconWidget, SocialDto social) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 48, 48, 48),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (social.followersCount != null && social.followersCount! > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatFollowersCount(social.followersCount!),
                style: const TextStyle(
                  fontSize: 10, 
                  color: Color.fromARGB(255, 48, 48, 48)
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String defaultProfileUrl = 'https://i.pravatar.cc/150?img=${influencer.id}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InfluencerDetailPage(influencer: influencer),
          ),
        );
      },
      child: SizedBox(
        width: 170, // Aumentado de 150 a 170
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Fondo blanco con bordes redondeados
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // Imagen de portada (banner)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade200,
                          Colors.pink.shade200,
                          Colors.orange.shade200,
                        ],
                      ),
                    ),
                    child: influencer.influencerBanner != null
                        ? Image.network(
                            influencer.influencerBanner!.url,
                            height: 60,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.purple.shade200,
                                      Colors.pink.shade200,
                                      Colors.orange.shade200,
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Avatar (foto de perfil)
              Positioned(
                top: 20,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      influencer.influencerLogo?.url ?? defaultProfileUrl,
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback manejado por defaultProfileUrl
                    },
                  ),
                ),
              ),

              // Contenido de texto
              Positioned(
                top: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nombre del influencer
                    SizedBox(
                      width: 140,
                      child: Text(
                        influencer.influencerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Alias (@username)
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 140,
                      child: Text(
                        '@${influencer.alias}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Categoría
                    Container(
                      padding: const EdgeInsets.all(1), // Padding para el borde degradado
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFC20B0C),
                            Color(0xFF7E0F9D),
                            Color(0xFF2616C7)
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color(0xFFC20B0C),
                              Color(0xFF7E0F9D),
                              Color(0xFF2616C7)
                            ],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            influencer.category != 'N/A' 
                                ? influencer.category 
                                : 'No Categoría',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white, // Color base requerido por ShaderMask
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Redes sociales
                    _buildSocialNetworksRow(),

                    const SizedBox(height: 4),

                    // Descripción/Summary
                    SizedBox(
                      width: 140,
                      child: Text(
                        influencer.summary != 'N/A'
                            ? influencer.summary
                            : 'Tendencias de moda, tutoriales de maquillaje, y consejos de est...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
