class EntrepreneurshipResponse {
  final List<Entrepreneurship> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final bool empty;

  EntrepreneurshipResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory EntrepreneurshipResponse.fromJson(Map<String, dynamic> json) {
    return EntrepreneurshipResponse(
      content: (json['content'] as List)
          .map((item) => Entrepreneurship.fromJson(item))
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

class Entrepreneurship {
  final int id;
  final String entrepreneurshipName;
  final String entrepreneursNickname;
  final String entrepreneurshipRUC;
  final String category;
  final String summary;
  final String description;
  final bool showOwnerName;
  final String addressType;
  final List<String> addresses;
  final List<String> entrepreneurFocus;
  final List<SocialDto> socialDtos;
  final MediaFile? entrepreneurLogo;
  final MediaFile? entrepreneurBanner;
  final List<MediaFile> s3Files;

  Entrepreneurship({
    required this.id,
    required this.entrepreneurshipName,
    required this.entrepreneursNickname,
    required this.entrepreneurshipRUC,
    required this.category,
    required this.summary,
    required this.description,
    required this.showOwnerName,
    required this.addressType,
    required this.addresses,
    required this.entrepreneurFocus,
    required this.socialDtos,
    this.entrepreneurLogo,
    this.entrepreneurBanner,
    required this.s3Files,
  });

  factory Entrepreneurship.fromJson(Map<String, dynamic> json) {
    return Entrepreneurship(
      id: json['id'],
      entrepreneurshipName:
          json['entrepreneurshipInformationEntrepreneurshipName'] ?? 'N/A',
      entrepreneursNickname:
          json['entrepreneurshipInformationEntrepreneursNickname'] ?? 'N/A',
      entrepreneurshipRUC:
          json['entrepreneurshipInformationEntrepreneurshipRUC'] ?? 'N/A',
      category: json['entrepreneurshipInformationCategory'] ?? 'N/A',
      summary: json['entrepreneurshipInformationSummary'] ?? 'N/A',
      description: json['entrepreneurshipInformationDescription'] ?? 'N/A',
      showOwnerName: json['showOwnerName'] ?? false,
      addressType: json['entrepreneurAddressAddressType'] ?? 'N/A',
      addresses: json['entrepreneurAddresses'] != null
          ? List<String>.from(json['entrepreneurAddresses'])
          : [],
      entrepreneurFocus: json['entrepreneurFocus'] != null
          ? List<String>.from(json['entrepreneurFocus'])
          : [],
      socialDtos: json['socialDtos'] != null
          ? (json['socialDtos'] as List)
              .map((item) => SocialDto.fromJson(item))
              .toList()
          : [],
      entrepreneurLogo: json['entrepreneurLogo'] != null
          ? MediaFile.fromJson(json['entrepreneurLogo'])
          : null,
      entrepreneurBanner: json['entrepreneurBanner'] != null
          ? MediaFile.fromJson(json['entrepreneurBanner'])
          : null,
      s3Files: json['s3Files'] != null
          ? (json['s3Files'] as List)
              .map((item) => MediaFile.fromJson(item))
              .toList()
          : [],
    );
  }
}

class SocialDto {
  final String name;
  final String socialUrl;

  SocialDto({
    required this.name,
    required this.socialUrl,
  });

  factory SocialDto.fromJson(Map<String, dynamic> json) {
    return SocialDto(
      name: json['name'],
      socialUrl: json['socialUrl'],
    );
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
}
