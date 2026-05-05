import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/routine_model.dart';
import '../model_ps/routine_model.dart';

class RoutinesService {
  final _db = Supabase.instance.client;

  Future<List<RoutineTemplate>> getAllRoutines() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await _db
        .from('routines')
        .select()
        .eq('created_by', userId)
        .eq('is_active', true);

    final routinesData = List<Map<String, dynamic>>.from(res as List);
    if (routinesData.isEmpty) return [];

    final routineIds = routinesData.map((r) => r['id'] as String).toList();

    // 1. Obtener patrones de respiración
    final patternsResponse = await _db
        .from('breathing_patterns')
        .select()
        .inFilter('routine_id', routineIds);

    final patternRows = List<Map<String, dynamic>>.from(
      patternsResponse as List,
    );
    final patternsByRoutine = {
      for (final row in patternRows)
        row['routine_id'] as String: BreathingPatternModel.fromMap(row),
    };

    // 2. Obtener assets de audio
    final audiosByRoutine = await _fetchAudioAssets(routineIds);

    return routinesData
        .map(
          (j) => RoutineTemplate.fromJson(
            j,
            breathingPattern: patternsByRoutine[j['id'] as String],
            audioUrl: audiosByRoutine[j['id'] as String],
          ),
        )
        .toList();
  }

  Future<Map<String, String>> _fetchAudioAssets(List<String> routineIds) async {
    if (routineIds.isEmpty) return {};

    try {
      final assetsResponse = await _db
          .from('routine_assets')
          .select('routine_id, storage_path, storage_bucket, file_type')
          .eq('is_active', true)
          .inFilter('routine_id', routineIds);

      final assetRows = List<Map<String, dynamic>>.from(assetsResponse as List);
      final audiosByRoutine = <String, String>{};

      for (final row in assetRows) {
        final path = row['storage_path'] as String;
        final bucket = row['storage_bucket'] as String? ?? 'routine-assets';

        if (path.startsWith('http')) {
          audiosByRoutine[row['routine_id'] as String] = path;
        } else {
          // Intentamos obtener la URL pública del bucket correspondiente
          final url = _db.storage.from(bucket).getPublicUrl(path);
          audiosByRoutine[row['routine_id'] as String] = url;
        }
      }
      return audiosByRoutine;
    } catch (e) {
      debugPrint("Error fetching audio assets for pro: $e");
      return {};
    }
  }

  /// Obtiene las categorías del ENUM routine_category reflejando la estructura de Supabase
  Future<List<String>> getEnumCategories() async {
    // Sincronizado manualmente con el CREATE TYPE routine_category de Supabase
    return [
      'relaxation',
      'breathing',
      'sleep_induction',
      'soundscape',
      'terapia_sonido',
    ];
  }

  /// Paso A: Crear la rutina base
  Future<Map<String, dynamic>> createBaseRoutine({
    required String title,
    required String description,
    required String category,
    required int durationSeconds,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception("Sesión no iniciada");

    return await _db
        .from('routines')
        .insert({
          'title': title,
          'description': description,
          'category': category,
          'duration_seconds': durationSeconds,
          'created_by': userId,
          'content_status': 'active',
          'is_visible_to_patients': true,
        })
        .select()
        .single();
  }

  /// Paso C (Opción Respiración): Guardar patrón
  Future<void> saveBreathingPattern({
    required String routineId,
    required int inhale,
    required int holdIn,
    required int exhale,
    required int holdOut,
    required int cyclesRecommended,
  }) async {
    await _db.from('breathing_patterns').insert({
      'routine_id': routineId,
      'inhale_sec': inhale,
      'hold_in_sec': holdIn,
      'exhale_sec': exhale,
      'hold_out_sec': holdOut,
      'cycles_recommended': cyclesRecommended,
    });
  }

  /// Paso C (Opción Audio): Subir a Storage y guardar en routine_assets
  Future<void> uploadRoutineAudio({
    required String routineId,
    required File audioFile,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(audioFile.path)}';

    // Nueva ruta organizada dentro de tu bucket 'psicologos'
    final storagePath = 'sonidos/routines/$routineId/$fileName';

    try {
      // 1. Subir al bucket 'psicologos'
      await _db.storage
          .from('psicologos')
          .upload(
            storagePath,
            audioFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Registrar en routine_assets
      await _db.from('routine_assets').insert({
        'routine_id': routineId,
        'storage_bucket': 'psicologos',
        'storage_path': storagePath,
        'file_type': 'audio',
        'file_size_bytes': await audioFile.length(),
      });
    } catch (e) {
      throw Exception(
        "Error de Storage: Verifica que el bucket 'psicologos' exista y tenga políticas RLS. Detalle: $e",
      );
    }
  }

  /// Paso C (Opción Audio Externo): Registrar URL de favoritos en routine_assets
  Future<void> saveExternalRoutineAudio({
    required String routineId,
    required String externalUrl,
    required String bucketLabel,
  }) async {
    await _db.from('routine_assets').insert({
      'routine_id': routineId,
      'storage_bucket': bucketLabel, // Guardamos el nombre + external
      'storage_path': externalUrl,
      'file_type': 'audio',
      'file_size_bytes': 0,
    });
  }

  /// Obtiene los favoritos del profesional actual
  Future<List<Map<String, dynamic>>> getProfessionalFavorites() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    return await _db
        .from('professional_favorites')
        .select()
        .eq('professional_id', userId);
  }

  Future<void> assignTask(String patientId, String routineId) async {
    final proId = _db.auth.currentUser?.id;
    if (proId == null) throw Exception("Sesión profesional no válida");

    await _db.from('assignments').insert({
      'patient_id': patientId,
      'professional_id': proId,
      'routine_id': routineId,
      'status': 'pending',
    });
  }
}
