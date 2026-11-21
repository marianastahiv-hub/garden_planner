import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/garden_repository.dart';
import '../../../data/garden_seed_data.dart';
import '../../../models/garden_gallery_entry.dart';
import '../../../models/garden_plant.dart';
import '../../../models/garden_task.dart';
import '../../../models/garden_zone.dart';
import 'garden_event.dart';
import 'garden_state.dart';

/// Loads shared garden lists and coordinates every create/update/delete action.
class GardenBloc extends Bloc<GardenEvent, GardenState> {
  GardenBloc(this._repository) : super(const GardenState()) {
    on<GardenLoadRequested>(_load);
    on<GardenZoneAdded>(
      (event, emit) => _save(emit, zones: [...state.zones, event.zone]),
    );
    on<GardenZoneUpdated>(
      (event, emit) => _save(
        emit,
        zones: state.zones
            .map((item) => item.id == event.zone.id ? event.zone : item)
            .toList(),
      ),
    );
    on<GardenZoneRemoved>(
      (event, emit) => _save(
        emit,
        zones: state.zones.where((item) => item.id != event.id).toList(),
      ),
    );
    on<GardenPlantAdded>(
      (event, emit) => _save(emit, plants: [...state.plants, event.plant]),
    );
    on<GardenPlantUpdated>(
      (event, emit) => _save(
        emit,
        plants: state.plants
            .map((item) => item.id == event.plant.id ? event.plant : item)
            .toList(),
      ),
    );
    on<GardenPlantRemoved>(
      (event, emit) => _save(
        emit,
        plants: state.plants.where((item) => item.id != event.id).toList(),
      ),
    );
    on<GardenGalleryEntryAdded>(
      (event, emit) =>
          _save(emit, galleryEntries: [...state.galleryEntries, event.entry]),
    );
    on<GardenGalleryEntryUpdated>(
      (event, emit) => _save(
        emit,
        galleryEntries: state.galleryEntries
            .map((item) => item.id == event.entry.id ? event.entry : item)
            .toList(),
      ),
    );
    on<GardenGalleryEntryRemoved>(
      (event, emit) => _save(
        emit,
        galleryEntries: state.galleryEntries
            .where((item) => item.id != event.id)
            .toList(),
      ),
    );
    on<GardenTaskAdded>(
      (event, emit) => _save(emit, tasks: [...state.tasks, event.task]),
    );
    on<GardenTaskUpdated>(
      (event, emit) => _save(
        emit,
        tasks: state.tasks
            .map((item) => item.id == event.task.id ? event.task : item)
            .toList(),
      ),
    );
    on<GardenTaskRemoved>(
      (event, emit) => _save(
        emit,
        tasks: state.tasks.where((item) => item.id != event.id).toList(),
      ),
    );
  }

  final GardenRepository _repository;
  Future<void> _writeQueue = Future<void>.value();

  Future<void> _load(
    GardenLoadRequested event,
    Emitter<GardenState> emit,
  ) async {
    if (state.userId == event.userId && state.status != GardenStatus.initial) {
      return;
    }
    emit(
      state.copyWith(
        status: GardenStatus.loading,
        userId: event.userId,
        clearError: true,
      ),
    );
    try {
      final data = await _repository.load(userId: event.userId) ?? _seedData();
      emit(
        state.copyWith(
          status: GardenStatus.loaded,
          userId: event.userId,
          zones: data.zones,
          plants: data.plants,
          tasks: data.tasks,
          galleryEntries: data.galleryEntries,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GardenStatus.failure,
          errorMessage: 'Could not load garden data.',
        ),
      );
      return;
    }
    try {
      final data = GardenData(
        zones: state.zones,
        plants: state.plants,
        tasks: state.tasks,
        galleryEntries: state.galleryEntries,
      );
      await _persist(data, event.userId);
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage:
              'Garden data loaded, but could not be saved on this device.',
        ),
      );
    }
  }

  Future<void> _save(
    Emitter<GardenState> emit, {
    List<GardenZone>? zones,
    List<GardenPlant>? plants,
    List<GardenTask>? tasks,
    List<GardenGalleryEntry>? galleryEntries,
  }) async {
    final data = GardenData(
      zones: zones ?? state.zones,
      plants: plants ?? state.plants,
      tasks: tasks ?? state.tasks,
      galleryEntries: galleryEntries ?? state.galleryEntries,
    );
    emit(
      state.copyWith(
        status: GardenStatus.loaded,
        zones: data.zones,
        plants: data.plants,
        tasks: data.tasks,
        galleryEntries: data.galleryEntries,
        clearError: true,
      ),
    );
    try {
      final userId = state.userId;
      if (userId == null) return;
      await _persist(data, userId);
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage:
              'Changes are visible now but could not be saved on this device.',
        ),
      );
    }
  }

  Future<void> _persist(GardenData data, String userId) {
    final write = _writeQueue.then(
      (_) => _repository.save(userId: userId, data: data),
    );
    _writeQueue = write.catchError((Object _) {});
    return write;
  }

  GardenData _seedData() {
    return GardenSeedData.create();
  }
}
