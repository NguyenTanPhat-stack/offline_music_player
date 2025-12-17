import 'dart:async';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';

enum SortBy { title, artist, album, dateAdded }

class MusicLibraryService {
  final OnAudioQuery _query = OnAudioQuery();

  SongSortType _toSortType(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.artist:
        return SongSortType.ARTIST;
      case SortBy.album:
        return SongSortType.ALBUM;
      case SortBy.dateAdded:
        return SongSortType.DATE_ADDED;
      case SortBy.title:
        return SongSortType.TITLE;
    }
  }

  Future<List<SongModelX>> getAllSongs({SortBy sortBy = SortBy.title}) async {
    // nếu chưa có quyền -> trả rỗng để UI khỏi đứng
    final ok = await _query.permissionsStatus();
    if (!ok) return [];

    final result = await _query
        .querySongs(
          sortType: _toSortType(sortBy),
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        )
        .timeout(const Duration(seconds: 8), onTimeout: () => []);

    return result.map(SongModelX.fromAudioQuery).toList();
  }
}
