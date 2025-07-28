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
  final String influencerNickname;
  final String influencerHandle; // @username
  final String category;
  final String summary;
  final String description;
  final bool showRealName;
  final List<String> addresses;
  final List<String> specialties;
  final List<SocialDto> socialDtos;
  final MediaFile? influencerProfileImage;
  final MediaFile? influencerBanner;
  final List<MediaFile> portfolioFiles;
  final int followersCount;
  final int collaborationsCount;
  final double rating;
  final bool isVerified;
  final DateTime? createdAt;

  Influencer({
    required this.id,
    required this.influencerName,
    required this.influencerNickname,
    required this.influencerHandle,
    required this.category,
    required this.summary,
    required this.description,
    required this.showRealName,
    required this.addresses,
    required this.specialties,
    required this.socialDtos,
    this.influencerProfileImage,
    this.influencerBanner,
    required this.portfolioFiles,
    required this.followersCount,
    required this.collaborationsCount,
    required this.rating,
    this.isVerified = false,
    this.createdAt,
  });

  factory Influencer.fromJson(Map<String, dynamic> json) {
    // Debug: imprimir los datos que llegan
    print('DEBUG - JSON recibido: $json');
    
    return Influencer(
      id: json['id'] ?? 0,
      //influencerName: json['influencerName'] ?? 
                     //json['influencerInformationInfluencerName'] ?? 
                     //json['name'] ?? 'N/A',
      influencerName: json['entrepreneurshipInformationEntrepreneurshipName'] ?? 'N/A',
      influencerNickname: json['influencerNickname'] ?? 
                         json['influencerInformationInfluencerNickname'] ?? 
                         json['nickname'] ?? 'N/A',
      influencerHandle: json['influencerHandle'] ?? 
                       json['influencerInformationInfluencerHandle'] ?? 
                       json['handle'] ?? '@unknown',
      category: json['category'] ?? 
               json['influencerInformationCategory'] ?? 
               json['influencerCategory'] ?? 'N/A',
      summary: json['summary'] ?? 
              json['influencerInformationSummary'] ?? 
              json['influencerSummary'] ?? 'N/A',
      description: json['description'] ?? 
                  json['influencerInformationDescription'] ?? 
                  json['influencerDescription'] ?? 'N/A',
      showRealName: json['showRealName'] ?? false,
      addresses: json['addresses'] != null
          ? List<String>.from(json['addresses'])
          : json['influencerAddresses'] != null
          ? List<String>.from(json['influencerAddresses'])
          : [],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : json['influencerSpecialties'] != null
          ? List<String>.from(json['influencerSpecialties'])
          : [],
      socialDtos: json['socialDtos'] != null
          ? (json['socialDtos'] as List)
              .map((item) => SocialDto.fromJson(item))
              .toList()
          : json['socials'] != null
          ? (json['socials'] as List)
              .map((item) => SocialDto.fromJson(item))
              .toList()
          : [],
      influencerProfileImage: json['influencerProfileImage'] != null
          ? MediaFile.fromJson(json['influencerProfileImage'])
          : json['profileImage'] != null
          ? MediaFile.fromJson(json['profileImage'])
          : null,
      influencerBanner: json['influencerBanner'] != null
          ? MediaFile.fromJson(json['influencerBanner'])
          : json['banner'] != null
          ? MediaFile.fromJson(json['banner'])
          : null,
      portfolioFiles: json['portfolioFiles'] != null
          ? (json['portfolioFiles'] as List)
              .map((item) => MediaFile.fromJson(item))
              .toList()
          : json['portfolio'] != null
          ? (json['portfolio'] as List)
              .map((item) => MediaFile.fromJson(item))
              .toList()
          : [],
      followersCount: json['followersCount'] ?? json['followers'] ?? 0,
      collaborationsCount: json['collaborationsCount'] ?? json['collaborations'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'influencerInformationInfluencerName': influencerName,
      'influencerInformationInfluencerNickname': influencerNickname,
      'influencerInformationInfluencerHandle': influencerHandle,
      'influencerInformationCategory': category,
      'influencerInformationSummary': summary,
      'influencerInformationDescription': description,
      'showRealName': showRealName,
      'influencerAddresses': addresses,
      'influencerSpecialties': specialties,
      'socialDtos': socialDtos.map((social) => social.toJson()).toList(),
      'influencerProfileImage': influencerProfileImage?.toJson(),
      'influencerBanner': influencerBanner?.toJson(),
      'portfolioFiles': portfolioFiles.map((file) => file.toJson()).toList(),
      'followersCount': followersCount,
      'collaborationsCount': collaborationsCount,
      'rating': rating,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
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
      name: json['name'],
      socialUrl: json['socialUrl'],
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
      id: json['id'],
      filename: json['filename'],
      contentType: json['contentType'],
      url: json['url'],
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
