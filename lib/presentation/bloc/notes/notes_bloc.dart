import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/note_entity.dart';
import '../../../domain/usecases/notes/get_notes_usecase.dart';
import '../../../domain/usecases/notes/create_note_usecase.dart';
import '../../../domain/usecases/notes/update_note_usecase.dart';
import '../../../domain/usecases/notes/delete_note_usecase.dart';
import '../../../domain/usecases/notes/search_notes_usecase.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final SearchNotesUseCase searchNotesUseCase;

  // Current filter and sort settings
  NotesFilter _currentFilter = const NotesFilter();
  NotesSortType _currentSortType = NotesSortType.updatedAt;
  bool _sortAscending = false;

  NotesBloc({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.searchNotesUseCase,
  }) : super(NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes);
    on<ToggleNotePinEvent>(_onToggleNotePin);
    on<ToggleNoteFavoriteEvent>(_onToggleNoteFavorite);
    on<RefreshNotesEvent>(_onRefreshNotes);
    on<LoadNotesByDateEvent>(_onLoadNotesByDate);
    on<FilterNotesEvent>(_onFilterNotes);
    on<SortNotesEvent>(_onSortNotes);
  }

  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) async {
    print('🔍 LoadNotesEvent: userId=${event.userId}, limit=${event.limit}, offset=${event.offset}');
    print('🔍 Previous state was: ${state.runtimeType}');
    emit(NotesLoading());

    final result = await getNotesUseCase(GetNotesParams(
      userId: event.userId,
      isPinned: event.isPinned,
      tags: event.tags,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) => {
        print('❌ LoadNotes failed: ${failure.message}'),
        emit(NotesError(failure.message))
      },
      (notes) {
        print('📊 Raw notes loaded: ${notes.length} notes');
        print('🔧 Current filter: showPinned=${_currentFilter.showPinned}, showFavorites=${_currentFilter.showFavorites}');
        
        final processedNotes = _applySortAndFilter(notes);
        print('📊 After filter/sort: ${processedNotes.length} notes');
        
        final pinnedNotes = processedNotes.where((note) => note.isPinned).toList();
        final recentNotes = processedNotes.where((note) => !note.isPinned).toList();
        
        print('📌 Pinned notes: ${pinnedNotes.length}');
        print('📝 Recent notes: ${recentNotes.length}');
        
        emit(NotesLoaded(
          notes: processedNotes,
          pinnedNotes: pinnedNotes,
          recentNotes: recentNotes,
        ));
      },
    );
  }

  Future<void> _onCreateNote(CreateNoteEvent event, Emitter<NotesState> emit) async {
    final result = await createNoteUseCase(CreateNoteParams(
      title: event.note.title,
      content: event.note.content,
      tags: event.note.tags,
      isPinned: event.note.isPinned,
      isEncrypted: event.note.isEncrypted,
      password: event.note.password,
      color: event.note.color,
      userId: event.note.userId,
      isFavorite: event.note.isFavorite,
      attachments: event.note.attachments,
      metadata: event.note.metadata,
      createdAt: event.note.createdAt,
      updatedAt: event.note.updatedAt,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (noteId) {
        emit(NoteCreated(noteId));
        // Auto-refresh to show the new note
        add(RefreshNotesEvent(event.note.userId));
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    final result = await updateNoteUseCase(UpdateNoteParams(
      noteId: event.note.id,
      title: event.note.title,
      content: event.note.content,
      tags: event.note.tags,
      isPinned: event.note.isPinned,
      isEncrypted: event.note.isEncrypted,
      password: event.note.password,
      color: event.note.color,
      isFavorite: event.note.isFavorite,
      attachments: event.note.attachments,
      metadata: event.note.metadata,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(NoteUpdated());
        // Auto-refresh to show updated note
        add(RefreshNotesEvent(event.note.userId));
      },
    );
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    final result = await deleteNoteUseCase(event.noteId);

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(NoteDeleted());
        // Auto-refresh to remove deleted note
        add(RefreshNotesEvent('user_1')); // TODO: Get from user session
      },
    );
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NotesState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(NotesSearchEmpty());
      return;
    }

    emit(NotesSearching());

    final result = await searchNotesUseCase(SearchNotesParams(
      query: event.query,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesSearchResults(notes)),
    );
  }

  Future<void> _onToggleNotePin(ToggleNotePinEvent event, Emitter<NotesState> emit) async {
    final result = await updateNoteUseCase(UpdateNoteParams(
      noteId: event.noteId,
      isPinned: event.isPinned,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(NotePinToggled());
      },
    );
  }

  Future<void> _onToggleNoteFavorite(ToggleNoteFavoriteEvent event, Emitter<NotesState> emit) async {
    final result = await updateNoteUseCase(UpdateNoteParams(
      noteId: event.noteId,
      isFavorite: event.isFavorite,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(NoteFavoriteToggled());
      },
    );
  }

  Future<void> _onRefreshNotes(RefreshNotesEvent event, Emitter<NotesState> emit) async {
    print('🔄 RefreshNotesEvent: userId=${event.userId}');
    add(LoadNotesEvent(userId: event.userId)); // From: RefreshNotesEvent
  }

  Future<void> _onLoadNotesByDate(LoadNotesByDateEvent event, Emitter<NotesState> emit) async {
    print('📅 LoadNotesByDateEvent: date=${event.date}, userId=${event.userId}');

    final result = await getNotesUseCase(GetNotesParams(
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) {
        // Filter notes by the selected date
        final startOfDay = DateTime(event.date.year, event.date.month, event.date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final notesForDate = notes.where((note) {
          final createdAt = note.createdAt ?? DateTime.now();
          return createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay);
        }).toList();

        final processedFilteredNotes = _applySortAndFilter(notesForDate);
        final processedAllNotes = _applySortAndFilter(notes);

        print('📅 LoadNotesByDate result: ${processedFilteredNotes.length} notes for date ${event.date}');
        print('📅 Preserving ${processedAllNotes.length} total notes in calendar state');
        
        // Emit calendar-specific state that doesn't interfere with main note list
        emit(NotesCalendarLoaded(
          allNotes: processedAllNotes,
          filteredNotes: processedFilteredNotes,
          selectedDate: event.date,
        ));
      },
    );
  }

  Future<void> _onFilterNotes(FilterNotesEvent event, Emitter<NotesState> emit) async {
    print('🔍 FilterNotesEvent: showPinned=${event.filter.showPinned}, showFavorites=${event.filter.showFavorites}');
    _currentFilter = event.filter;
    
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      final filteredNotes = _applyFilterToNotes(currentState.notes);
      final sortedNotes = _applySortToNotes(filteredNotes);
      
      print('🔧 FilterNotesEvent result: ${sortedNotes.length} notes after filter');
      emit(NotesLoaded(
        notes: sortedNotes,
        pinnedNotes: sortedNotes.where((note) => note.isPinned).toList(),
        recentNotes: sortedNotes.where((note) => !note.isPinned).toList(),
      ));
    } else {
      // Reload notes with new filter
      print('⚠️  FilterNotesEvent: State is not NotesLoaded (${state.runtimeType}), triggering reload');
      add(const LoadNotesEvent(userId: 'user_1')); // From: FilterNotesEvent fallback
    }
  }

  Future<void> _onSortNotes(SortNotesEvent event, Emitter<NotesState> emit) async {
    print('📊 SortNotesEvent: sortType=${event.sortType}, ascending=${event.ascending}');
    _currentSortType = event.sortType;
    _sortAscending = event.ascending;
    
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      final sortedNotes = _applySortToNotes(currentState.notes);
      
      print('📊 SortNotesEvent result: ${sortedNotes.length} notes after sort');
      emit(NotesLoaded(
        notes: sortedNotes,
        pinnedNotes: sortedNotes.where((note) => note.isPinned).toList(),
        recentNotes: sortedNotes.where((note) => !note.isPinned).toList(),
      ));
    }
  }

  List<NoteEntity> _applySortAndFilter(List<NoteEntity> notes) {
    final filteredNotes = _applyFilterToNotes(notes);
    return _applySortToNotes(filteredNotes);
  }

  List<NoteEntity> _applyFilterToNotes(List<NoteEntity> notes) {
    var filteredNotes = notes;

    // Apply pinned filter
    if (_currentFilter.showPinned != null) {
      filteredNotes = filteredNotes.where((note) => 
        note.isPinned == _currentFilter.showPinned).toList();
    }

    // Apply favorites filter
    if (_currentFilter.showFavorites != null) {
      filteredNotes = filteredNotes.where((note) => 
        note.isFavorite == _currentFilter.showFavorites).toList();
    }

    // Apply tags filter
    if (_currentFilter.tags != null && _currentFilter.tags!.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) =>
        _currentFilter.tags!.any((filterTag) => 
          note.tags.contains(filterTag))).toList();
    }

    // Apply search query filter
    if (_currentFilter.searchQuery != null && 
        _currentFilter.searchQuery!.trim().isNotEmpty) {
      final query = _currentFilter.searchQuery!.toLowerCase();
      filteredNotes = filteredNotes.where((note) =>
        note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query) ||
        note.tags.any((tag) => tag.toLowerCase().contains(query))).toList();
    }

    return filteredNotes;
  }

  List<NoteEntity> _applySortToNotes(List<NoteEntity> notes) {
    final sortedNotes = List<NoteEntity>.from(notes);

    sortedNotes.sort((a, b) {
      int comparison = 0;

      switch (_currentSortType) {
        case NotesSortType.createdAt:
          comparison = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
          break;
        case NotesSortType.updatedAt:
          comparison = (a.updatedAt ?? DateTime.now())
              .compareTo(b.updatedAt ?? DateTime.now());
          break;
        case NotesSortType.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case NotesSortType.isPinned:
          comparison = b.isPinned.toString().compareTo(a.isPinned.toString());
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedNotes;
  }

  // Getters for current filter and sort state
  NotesFilter get currentFilter => _currentFilter;
  NotesSortType get currentSortType => _currentSortType;
  bool get sortAscending => _sortAscending;
}