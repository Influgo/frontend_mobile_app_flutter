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
    return Influencer(
      id: json['id'],
      influencerName: json['influencerInformationInfluencerName'] ?? 'N/A',
      influencerNickname: json['influencerInformationInfluencerNickname'] ?? 'N/A',
      influencerHandle: json['influencerInformationInfluencerHandle'] ?? '@unknown',
      category: json['influencerInformationCategory'] ?? 'N/A',
      summary: json['influencerInformationSummary'] ?? 'N/A',
      description: json['influencerInformationDescription'] ?? 'N/A',
      showRealName: json['showRealName'] ?? false,
      specialties: json['influencerSpecialties'] != null
          ? List<String>.from(json['influencerSpecialties'])
          : [],
      socialDtos: json['socialDtos'] != null
          ? (json['socialDtos'] as List)
              .map((item) => SocialDto.fromJson(item))
              .toList()
          : [],
      influencerProfileImage: json['influencerProfileImage'] != null
          ? MediaFile.fromJson(json['influencerProfileImage'])
          : null,
      influencerBanner: json['influencerBanner'] != null
          ? MediaFile.fromJson(json['influencerBanner'])
          : null,
      portfolioFiles: json['portfolioFiles'] != null
          ? (json['portfolioFiles'] as List)
              .map((item) => MediaFile.fromJson(item))
              .toList()
          : [],
      followersCount: json['followersCount'] ?? 0,
      collaborationsCount: json['collaborationsCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
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
