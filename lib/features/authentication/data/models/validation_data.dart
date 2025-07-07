import 'dart:typed_data';

class ValidationData {
  String selectedProfile = "";
  Map<String, dynamic> requestBody = {};
  Uint8List? anversoImage;
  Uint8List? reversoImage;
  Uint8List? perfilImage;

  ValidationData({
    this.selectedProfile = "",
    Map<String, dynamic>? requestBody,
    this.anversoImage,
    this.reversoImage,
    this.perfilImage,
  }) : requestBody = requestBody ?? {};

  // Métodos helper para verificar si las imágenes están disponibles
  bool get hasAnversoImage => anversoImage != null;
  bool get hasReversoImage => reversoImage != null;
  bool get hasPerfilImage => perfilImage != null;
  bool get hasAllImages => hasAnversoImage && hasReversoImage && hasPerfilImage;

  // Método para limpiar las imágenes
  void clearImages() {
    anversoImage = null;
    reversoImage = null;
    perfilImage = null;
  }

  // Método para limpiar todo
  void clear() {
    selectedProfile = "";
    clearImages();
    requestBody.clear();
  }

  @override
  String toString() {
    return 'ValidationData{selectedProfile: $selectedProfile, '
        'anversoImage: ${anversoImage != null ? '${anversoImage!.length} bytes' : 'null'}, '
        'reversoImage: ${reversoImage != null ? '${reversoImage!.length} bytes' : 'null'}, '
        'perfilImage: ${perfilImage != null ? '${perfilImage!.length} bytes' : 'null'}, '
        'requestBody: $requestBody}';
  }
}
