import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearch {
  final String id;
  final String name;
  final String nickname;
  final String? logoUrl;
  final String type; // 'entrepreneur' o 'influencer'
  final DateTime timestamp;

  RecentSearch({
    required this.id,
    required this.name,
    required this.nickname,
    this.logoUrl,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'logoUrl': logoUrl,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'] ?? '',
      logoUrl: json['logoUrl'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class RecentSearchesService {
  static const int _maxRecentSearches =
      15; // Aumentado para búsquedas compartidas

  // Obtener el userId actual
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Generar la clave para las búsquedas del usuario (ahora compartidas)
  String _getRecentSearchesKey(String userId) {
    return 'recent_searches_shared_$userId';
  }

  // Obtener todas las búsquedas recientes del usuario actual (compartidas)
  Future<List<RecentSearch>> getRecentSearches() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final key = _getRecentSearchesKey(userId);
      final jsonString = prefs.getString(key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      final searches =
          jsonList.map((json) => RecentSearch.fromJson(json)).toList();

      // Ordenar por timestamp descendente (más recientes primero)
      searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return searches;
    } catch (e) {
      print('❌ Error obteniendo búsquedas recientes: $e');
      return [];
    }
  }

  // Obtener búsquedas recientes filtradas por tipo
  Future<List<RecentSearch>> getRecentSearchesByType(String type) async {
    final allSearches = await getRecentSearches();
    return allSearches.where((search) => search.type == type).toList();
  }

  // Añadir una nueva búsqueda reciente
  Future<void> addRecentSearch(RecentSearch search) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final searches = await getRecentSearches();

      // Remover si ya existe (para evitar duplicados y "subirlo" en la lista)
      searches.removeWhere((s) => s.id == search.id && s.type == search.type);

      // Añadir al inicio con timestamp actualizado
      final updatedSearch = RecentSearch(
        id: search.id,
        name: search.name,
        nickname: search.nickname,
        logoUrl: search.logoUrl,
        type: search.type,
        timestamp: DateTime.now(),
      );

      searches.insert(0, updatedSearch);

      // Mantener solo las últimas N búsquedas
      if (searches.length > _maxRecentSearches) {
        searches.removeRange(_maxRecentSearches, searches.length);
      }

      // Guardar en SharedPreferences
      await _saveSearches(userId, searches);

      print('✅ Búsqueda agregada: ${search.name} (${search.type})');
    } catch (e) {
      print('❌ Error añadiendo búsqueda reciente: $e');
    }
  }

  // Eliminar una búsqueda específica
  Future<void> removeRecentSearch(String searchId, String searchType) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final searches = await getRecentSearches();
      searches.removeWhere((s) => s.id == searchId && s.type == searchType);

      await _saveSearches(userId, searches);
      print('🗑️ Búsqueda eliminada: $searchId ($searchType)');
    } catch (e) {
      print('❌ Error eliminando búsqueda reciente: $e');
    }
  }

  // Limpiar todas las búsquedas recientes del usuario actual
  Future<void> clearAllRecentSearches() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = _getRecentSearchesKey(userId);
      await prefs.remove(key);

      print('🧹 Todas las búsquedas recientes eliminadas');
    } catch (e) {
      print('❌ Error limpiando búsquedas recientes: $e');
    }
  }

  // Limpiar búsquedas por tipo
  Future<void> clearRecentSearchesByType(String type) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final searches = await getRecentSearches();
      final filteredSearches = searches.where((s) => s.type != type).toList();

      await _saveSearches(userId, filteredSearches);
      print('🧹 Búsquedas recientes de tipo "$type" eliminadas');
    } catch (e) {
      print('❌ Error limpiando búsquedas recientes por tipo: $e');
    }
  }

  // Guardar las búsquedas en SharedPreferences
  Future<void> _saveSearches(String userId, List<RecentSearch> searches) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getRecentSearchesKey(userId);
    final jsonList = searches.map((s) => s.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // Migrar búsquedas del sistema anterior al nuevo (si es necesario)
  Future<void> migrateOldSearches() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();

      // Claves del sistema anterior
      final oldEntrepreneurKey = 'recent_searches_$userId';
      final oldInfluencerKey = 'recent_searches_influencer_$userId';

      List<RecentSearch> migratedSearches = [];

      // Migrar búsquedas de entrepreneurs
      final oldEntrepreneurString = prefs.getString(oldEntrepreneurKey);
      if (oldEntrepreneurString != null) {
        final List<dynamic> oldList = json.decode(oldEntrepreneurString);
        migratedSearches
            .addAll(oldList.map((json) => RecentSearch.fromJson(json)));
        await prefs.remove(oldEntrepreneurKey);
      }

      // Migrar búsquedas de influencers (si existen)
      final oldInfluencerString = prefs.getString(oldInfluencerKey);
      if (oldInfluencerString != null) {
        final List<dynamic> oldList = json.decode(oldInfluencerString);
        migratedSearches
            .addAll(oldList.map((json) => RecentSearch.fromJson(json)));
        await prefs.remove(oldInfluencerKey);
      }

      if (migratedSearches.isNotEmpty) {
        // Ordenar por fecha y mantener las más recientes
        migratedSearches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        if (migratedSearches.length > _maxRecentSearches) {
          migratedSearches = migratedSearches.take(_maxRecentSearches).toList();
        }

        await _saveSearches(userId, migratedSearches);
        print('✅ Migración completada: ${migratedSearches.length} búsquedas');
      }
    } catch (e) {
      print('❌ Error en migración: $e');
    }
  }

  // Crear RecentSearch desde Entrepreneurship
  static RecentSearch fromEntrepreneurship(dynamic entrepreneurship) {
    return RecentSearch(
      id: entrepreneurship.id.toString(),
      name: entrepreneurship.entrepreneurshipName,
      nickname: entrepreneurship.entrepreneursNickname ?? '',
      logoUrl: entrepreneurship.entrepreneurLogo?.url,
      type: 'entrepreneur',
      timestamp: DateTime.now(),
    );
  }

  // Crear RecentSearch desde Influencer (para cuando esté listo)
  static RecentSearch fromInfluencer(dynamic influencer) {
    return RecentSearch(
      id: influencer.id.toString(),
      name: influencer.name ?? 'Influencer',
      nickname: influencer.username ?? 'username',
      logoUrl: influencer.profileImage?.url,
      type: 'influencer',
      timestamp: DateTime.now(),
    );
  }

  // Crear RecentSearch manualmente (para búsquedas de texto)
  static RecentSearch createTextSearch(String searchText, String type) {
    return RecentSearch(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      name: searchText,
      nickname: '',
      logoUrl: null,
      type: type,
      timestamp: DateTime.now(),
    );
  }

  // Buscar en las búsquedas recientes
  Future<List<RecentSearch>> searchInRecentSearches(String query) async {
    if (query.trim().isEmpty) return [];

    final allSearches = await getRecentSearches();
    return allSearches
        .where((search) =>
            search.name.toLowerCase().contains(query.toLowerCase()) ||
            search.nickname.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
