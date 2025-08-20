part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NotesEvent {
  final String? userId;
  final bool? isPinned;
  final List<String>? tags;
  final int? limit;
  final int? offset;

  const LoadNotesEvent({
    this.userId,
    this.isPinned,
    this.tags,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, isPinned, tags, limit, offset];
}

class CreateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const CreateNoteEvent(this.note);

  @override
  List<Object> get props => [note];
}

class UpdateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object> get props => [note];
}

class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object> get props => [noteId];
}

class SearchNotesEvent extends NotesEvent {
  final String query;
  final String? userId;

  const SearchNotesEvent({
    required this.query,
    this.userId,
  });

  @override
  List<Object?> get props => [query, userId];
}

class ToggleNotePinEvent extends NotesEvent {
  final String noteId;
  final String userId;
  final bool isPinned;

  const ToggleNotePinEvent({
    required this.noteId,
    required this.userId,
    required this.isPinned,
  });

  @override
  List<Object> get props => [noteId, userId, isPinned];
}

class ToggleNoteFavoriteEvent extends NotesEvent {
  final String noteId;
  final String userId;
  final bool isFavorite;

  const ToggleNoteFavoriteEvent({
    required this.noteId,
    required this.userId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [noteId, userId, isFavorite];
}

class RefreshNotesEvent extends NotesEvent {
  final String? userId;

  const RefreshNotesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}