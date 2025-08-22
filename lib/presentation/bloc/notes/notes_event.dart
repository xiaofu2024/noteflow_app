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

class LoadNotesByDateEvent extends NotesEvent {
  final DateTime date;
  final String? userId;

  const LoadNotesByDateEvent({
    required this.date,
    this.userId,
  });

  @override
  List<Object?> get props => [date, userId];
}

class FilterNotesEvent extends NotesEvent {
  final NotesFilter filter;

  const FilterNotesEvent(this.filter);

  @override
  List<Object> get props => [filter];
}

class SortNotesEvent extends NotesEvent {
  final NotesSortType sortType;
  final bool ascending;

  const SortNotesEvent({
    required this.sortType,
    this.ascending = true,
  });

  @override
  List<Object> get props => [sortType, ascending];
}

enum NotesSortType {
  createdAt,
  updatedAt,
  title,
  isPinned,
}

class NotesFilter {
  final bool? showPinned;
  final bool? showFavorites;
  final List<String>? tags;
  final String? searchQuery;

  const NotesFilter({
    this.showPinned,
    this.showFavorites,
    this.tags,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesFilter &&
          runtimeType == other.runtimeType &&
          showPinned == other.showPinned &&
          showFavorites == other.showFavorites &&
          tags == other.tags &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      showPinned.hashCode ^
      showFavorites.hashCode ^
      tags.hashCode ^
      searchQuery.hashCode;
}