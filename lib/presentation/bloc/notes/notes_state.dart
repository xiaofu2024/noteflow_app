part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;
  final List<NoteEntity> pinnedNotes;
  final List<NoteEntity> recentNotes;

  const NotesLoaded({
    required this.notes,
    required this.pinnedNotes,
    required this.recentNotes,
  });

  @override
  List<Object> get props => [notes, pinnedNotes, recentNotes];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object> get props => [message];
}

class NoteCreated extends NotesState {
  final String noteId;

  const NoteCreated(this.noteId);

  @override
  List<Object> get props => [noteId];
}

class NoteUpdated extends NotesState {}

class NoteDeleted extends NotesState {}

class NotePinToggled extends NotesState {}

class NoteFavoriteToggled extends NotesState {}

class NotesSearching extends NotesState {}

class NotesSearchResults extends NotesState {
  final List<NoteEntity> results;

  const NotesSearchResults(this.results);

  @override
  List<Object> get props => [results];
}

class NotesSearchEmpty extends NotesState {}

class NotesCalendarLoaded extends NotesState {
  final List<NoteEntity> allNotes;
  final List<NoteEntity> filteredNotes;
  final DateTime selectedDate;

  const NotesCalendarLoaded({
    required this.allNotes,
    required this.filteredNotes,
    required this.selectedDate,
  });

  @override
  List<Object> get props => [allNotes, filteredNotes, selectedDate];
}