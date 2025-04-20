import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/entrepreneurship/data/models/entrepreneurship_model.dart';

class BusinessCardWidget extends StatelessWidget {
  final Entrepreneurship entrepreneurship;

  const BusinessCardWidget({
    super.key,
    required this.entrepreneurship,
  });

  @override
  Widget build(BuildContext context) {
    // Default placeholder images
    final String defaultBannerUrl =
        'https://cdn.pixabay.com/photo/2024/11/25/10/38/mountains-9223041_1280.jpg';
    final String defaultLogoUrl =
        'https://mir-s3-cdn-cf.behance.net/project_modules/1400/9b991924668429.56338097af083.jpg';

    return SizedBox(
      width: 150,
      height: 190,
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  entrepreneurship.entrepreneurBanner?.url ?? defaultBannerUrl,
                  height: 60,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      defaultBannerUrl,
                      height: 60,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            // Avatar (logo)
            Positioned(
              top: 20,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    entrepreneurship.entrepreneurLogo?.url ?? defaultLogoUrl,
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback to default image
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
                  /*Text(
                    entrepreneurship.entrepreneurshipName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),*/

                  SizedBox(
                    width: 120, // Controla el ancho máximo para que haga wrap
                    child: Text(
                      entrepreneurship.entrepreneurshipName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 2, // Permitir hasta 2 líneas
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Text(
                    '@${entrepreneurship.entrepreneursNickname}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Categoría
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      entrepreneurship.category != 'N/A'
                          ? entrepreneurship.category
                          : 'No Categoría',
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: 120,
                    child: Text(
                      entrepreneurship.summary != 'N/A'
                          ? entrepreneurship.summary
                          : 'Sin descripción disponible',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
