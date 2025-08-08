class InfluencerResponse {
  final List<Influencer> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final bool empty;

  InfluencerResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory InfluencerResponse.fromJson(Map<String, dynamic> json) {
    return InfluencerResponse(
      content: (json['content'] as List)
          .map((item) => Influencer.fromJson(item))
          .toList(),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      first: json['first'],
      last: json['last'],
      empty: json['empty'],
    );
  }
}

class Influencer {
  final int id;
  final String influencerName;
  final String alias;
  final String category;
  final String summary;
  final String description;
  final List<String> addresses;
  final List<String> influencerFocus;
  final List<SocialDto> socialDtos;
  final MediaFile? influencerLogo;
  final MediaFile? influencerBanner;
  final List<MediaFile> s3Files;

  Influencer({
    required this.id,
    required this.influencerName,
    required this.alias,
    required this.category,
    required this.summary,
    required this.description,
    required this.addresses,
    required this.influencerFocus,
    required this.socialDtos,
    this.influencerLogo,
    this.influencerBanner,
    required this.s3Files,
  });

  factory Influencer.fromJson(Map<String, dynamic> json) {
    return Influencer(
      id: json['id'] ?? 0,
      influencerName: json['influencerInformationInfluencerName'] ?? 
                     json['influencerName'] ?? 
                     json['name'] ?? 
                     json['eventName'] ?? // Fallback en caso de que sea un evento
                     'N/A',
      alias: json['alias'] ?? 'N/A',
      category: json['influencerInformationInfluencerCategory'] ?? 
               json['category'] ?? 'N/A',
      summary: json['summary'] ?? 
              json['influencerInformationInfluencerSummary'] ??
              json['influencerSummary'] ?? 
              json['eventDescription'] ?? // Fallback en caso de que sea un evento
              'N/A',
      description: json['influencerInformationInfluencerDescription'] ?? 
                  json['description'] ?? 
                  json['eventDescription'] ?? // Fallback en caso de que sea un evento
                  'N/A',
      addresses: _parseStringList(json['addresses'] ?? json['influencerAddress']),
      influencerFocus: _parseStringList(json['influencerFocus']),
      socialDtos: _parseSocialDtos(json['socialDtos'] ?? json['socials']),
      influencerLogo: _parseMediaFile(json['influencerLogo'] ?? 
                                    json['influencerProfileImage'] ?? 
                                    json['profileImage'] ??
                                    json['s3File']), // Fallback al s3File si es un evento
      influencerBanner: _parseMediaFile(json['influencerBanner'] ?? 
                                       json['banner']),
      s3Files: _parseMediaFileList(json['s3Files']),
    );
  }

  // Método para obtener redes sociales limitadas para tarjetas (máximo 2)
  List<SocialDto> get socialDtosForCards {
    // Si tiene 2 o menos redes, devolver todas
    if (socialDtos.length <= 2) {
      return socialDtos;
    }
    
    // Si tiene más de 2, priorizar Instagram y TikTok
    List<SocialDto> result = [];
    
    // Buscar Instagram y TikTok primero
    SocialDto? instagram;
    SocialDto? tiktok;
    
    for (SocialDto social in socialDtos) {
      String socialName = social.name.toLowerCase();
      if (socialName == 'instagram') {
        instagram = social;
      } else if (socialName == 'tiktok') {
        tiktok = social;
      }
    }
    
    if (instagram != null) result.add(instagram);
    if (tiktok != null) result.add(tiktok);
    
    // Si ya tenemos 2, devolver
    if (result.length >= 2) {
      return result;
    }
    
    // Si no tenemos 2, agregar las primeras que no sean Instagram/TikTok
    for (SocialDto social in socialDtos) {
      if (result.length >= 2) break;
      String socialName = social.name.toLowerCase();
      if (socialName != 'instagram' && socialName != 'tiktok') {
        result.add(social);
      }
    }
    
    return result;
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    if (data is String) {
      return [data];
    }
    return [];
  }

  static List<SocialDto> _parseSocialDtos(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      List<SocialDto> allSocials = data.map((item) {
        if (item is Map<String, dynamic>) {
          return SocialDto.fromJson(item);
        }
        return null;
      }).whereType<SocialDto>().toList();
      
      return allSocials;
      
    }
    return [];
  }

  static MediaFile? _parseMediaFile(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      try {
        return MediaFile.fromJson(data);
      } catch (e) {
        print('Error parsing MediaFile: $e');
        return null;
      }
    }
    return null;
  }

  static List<MediaFile> _parseMediaFileList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          try {
            return MediaFile.fromJson(item);
          } catch (e) {
            print('Error parsing MediaFile in list: $e');
            return null;
          }
        }
        return null;
      }).whereType<MediaFile>().toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'influencerInformationInfluencerName': influencerName,
      'alias': alias,
      'influencerInformationInfluencerCategory': category,
      'influencerInformationInfluencerSummary': summary,
      'influencerInformationInfluencerDescription': description,
      'influencerAddress': addresses,
      'socialDtos': socialDtos.map((social) => social.toJson()).toList(),
      'influencerProfileImage': influencerLogo?.toJson(),
      'influencerBanner': influencerBanner?.toJson(),
    };
  }
}

// Reutilizamos las clases SocialDto y MediaFile del modelo de Entrepreneurship
class SocialDto {
  final String name;
  final String socialUrl;
  final int? followersCount;

  SocialDto({
    required this.name,
    required this.socialUrl,
    this.followersCount,
  });

  factory SocialDto.fromJson(Map<String, dynamic> json) {
    return SocialDto(
      name: json['name'] ?? '',
      socialUrl: json['socialUrl'] ?? '',
      followersCount: json['followersCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'socialUrl': socialUrl,
      'followersCount': followersCount,
    };
  }
}

class MediaFile {
  final int id;
  final String filename;
  final String contentType;
  final String url;

  MediaFile({
    required this.id,
    required this.filename,
    required this.contentType,
    required this.url,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] ?? 0,
      filename: json['filename'] ?? '',
      contentType: json['contentType'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'contentType': contentType,
      'url': url,
    };
  }
}
