import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareEntrepreneurshipModal {
  static void show(
    BuildContext context, {
    required String entrepreneurshipId,
    required String entrepreneurshipName,
    required String summary,
    String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareModalContent(
        entrepreneurshipId: entrepreneurshipId,
        entrepreneurshipName: entrepreneurshipName,
        summary: summary,
        imageUrl: imageUrl,
      ),
    );
  }
}

class _ShareModalContent extends StatelessWidget {
  final String entrepreneurshipId;
  final String entrepreneurshipName;
  final String summary;
  final String? imageUrl;

  const _ShareModalContent({
    required this.entrepreneurshipId,
    required this.entrepreneurshipName,
    required this.summary,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final deepLink = 'influyo://entrepreneurship/$entrepreneurshipId';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'COMPARTIR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey[300]),

          // Opciones de compartir
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Primera fila - Redes sociales principales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      context,
                      icon: _buildTikTokIcon(),
                      label: 'TikTok',
                      onTap: () => _shareToTikTok(context, deepLink),
                    ),
                    _buildShareOption(
                      context,
                      icon: _buildInstagramIcon(),
                      label: 'Instagram',
                      onTap: () => _shareToInstagram(context, deepLink),
                    ),
                    _buildShareOption(
                      context,
                      icon: _buildWhatsAppIcon(),
                      label: 'WhatsApp',
                      onTap: () => _shareToWhatsApp(context, deepLink),
                    ),
                    _buildShareOption(
                      context,
                      icon: _buildFacebookIcon(),
                      label: 'Facebook',
                      onTap: () => _shareToFacebook(context, deepLink),
                    ),
                    _buildShareOption(
                      context,
                      icon: _buildGmailIcon(),
                      label: 'Gmail',
                      onTap: () => _shareToGmail(context, deepLink),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Opción de copiar vínculo
                GestureDetector(
                  onTap: () => _copyToClipboard(context, deepLink),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.copy_outlined,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Copiar vínculo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Espacio inferior para el safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            child: icon,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Iconos con logos reales usando FontAwesome (opción recomendada)
  Widget _buildTikTokIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Center(
        child: Icon(
          //Icons.music_note, // Cambiar por: FontAwesomeIcons.tiktok
          FontAwesomeIcons.tiktok,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildInstagramIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF833AB4),
            Color(0xFFE1306C),
            Color(0xFFFCAF45),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          //Icons.camera_alt_outlined, // Cambiar por: FontAwesomeIcons.instagram
          FontAwesomeIcons.instagram,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildWhatsAppIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF25D366),
      ),
      child: Center(
        child: Icon(
          //Icons.chat_bubble_outline, // Cambiar por: FontAwesomeIcons.whatsapp
          FontAwesomeIcons.whatsapp,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFacebookIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1877F2),
      ),
      child: Center(
        child: Icon(
          //Icons.facebook, // Cambiar por: FontAwesomeIcons.facebookF
          FontAwesomeIcons.facebookF,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildGmailIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Icon(
          //Icons.email_outlined, // Cambiar por: FontAwesomeIcons.envelope
          FontAwesomeIcons.envelope,
          color: Color(0xFFEA4335),
          size: 28,
        ),
      ),
    );
  }

  // Métodos para compartir en cada plataforma
  String _getShareText() {
    return '¡Mira este increíble emprendimiento! 🚀\n\n'
        '$entrepreneurshipName\n'
        '$summary\n\n'
        '#Emprendimiento #Influyo #Negocios';
  }

  void _shareToTikTok(BuildContext context, String deepLink) async {
    final text = _getShareText();
    final url =
        'https://www.tiktok.com/upload?text=${Uri.encodeComponent(text)}\n\n$deepLink';

    if (await canLaunchUrl(Uri.parse('tiktok://upload'))) {
      await launchUrl(Uri.parse('tiktok://upload'));
    } else {
      _copyToClipboard(context, '$text\n\n$deepLink');
    }
  }

  void _shareToInstagram(BuildContext context, String deepLink) async {
    final text = _getShareText();

    // Intentar abrir Instagram Direct (chat)
    final instagramDirectUrl = 'instagram://direct-share';
    final instagramUrl = 'instagram://user?username=';

    try {
      if (await canLaunchUrl(Uri.parse(instagramDirectUrl))) {
        await launchUrl(Uri.parse(instagramDirectUrl));
        _copyToClipboard(context, '$text\n\n$deepLink');
      } else if (await canLaunchUrl(Uri.parse(instagramUrl))) {
        await launchUrl(Uri.parse(instagramUrl));
        _copyToClipboard(context, '$text\n\n$deepLink');
      } else {
        // Si Instagram no está instalado, copiar al portapapeles
        _copyToClipboard(context, '$text\n\n$deepLink');
      }
    } catch (e) {
      _copyToClipboard(context, '$text\n\n$deepLink');
    }
  }

  void _shareToWhatsApp(BuildContext context, String deepLink) async {
    final text = _getShareText();
    final url =
        'whatsapp://send?text=${Uri.encodeComponent('$text\n\n$deepLink')}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _shareGeneric(context, '$text\n\n$deepLink');
    }
  }

  void _shareToFacebook(BuildContext context, String deepLink) async {
    final url =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(deepLink)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _shareGeneric(context, '${_getShareText()}\n\n$deepLink');
    }
  }

  void _shareToGmail(BuildContext context, String deepLink) async {
    final subject = Uri.encodeComponent(
        '¡Mira este emprendimiento: $entrepreneurshipName!');
    final body = Uri.encodeComponent('${_getShareText()}\n\n$deepLink');
    final url = 'mailto:?subject=$subject&body=$body';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _copyToClipboard(context, '${_getShareText()}\n\n$deepLink');
    }
  }

  void _shareGeneric(BuildContext context, String text) {
    // Aquí puedes usar share_plus si lo tienes instalado
    // Share.share(text);
    _copyToClipboard(context, text);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
