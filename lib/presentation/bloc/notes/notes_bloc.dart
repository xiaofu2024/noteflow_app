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
  }

  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) async {
    if (state is NotesLoading) return;
    
    emit(NotesLoading());

    final result = await getNotesUseCase(GetNotesParams(
      userId: event.userId,
      isPinned: event.isPinned,
      tags: event.tags,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesLoaded(
        notes: notes,
        pinnedNotes: notes.where((note) => note.isPinned).toList(),
        recentNotes: notes.where((note) => !note.isPinned).toList(),
      )),
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
    ));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (noteId) {
        // Reload notes after creation
        add(RefreshNotesEvent(event.note.userId));
        emit(NoteCreated(noteId));
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
        // Reload notes after update
        add(RefreshNotesEvent(event.note.userId));
        emit(NoteUpdated());
      },
    );
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    final result = await deleteNoteUseCase(event.noteId);

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        // Reload notes after deletion
        add(RefreshNotesEvent('user_1')); // TODO: Get from user session
        emit(NoteDeleted());
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
        add(RefreshNotesEvent(event.userId));
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
        add(RefreshNotesEvent(event.userId));
        emit(NoteFavoriteToggled());
      },
    );
  }

  Future<void> _onRefreshNotes(RefreshNotesEvent event, Emitter<NotesState> emit) async {
    add(LoadNotesEvent(userId: event.userId));
  }
}