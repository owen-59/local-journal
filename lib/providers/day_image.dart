import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/main.dart';
import 'package:journal/models/entry.dart';
import 'package:journal/providers/cache_entries.dart';

final dayImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, DateTime>((ref, DateTime dt) async {
      final entries = await ref.watch(cacheEntriesProvider.future);
      final rootFolder = ref.watch(folderUriProvider).toString();

      final firstEntry = entries
          .where(
            (entry) =>
                DateUtils.isSameDay(entry.createdDate, dt) &&
                entry.images?.isNotEmpty == true,
          )
          .toList()
          .elementAtOrNull(0);
      if (firstEntry == null) return null;

      final spoofEntry = Entry(
        body: "",
        datetime: dt,
        tags: [],
        images: [firstEntry.images![0]],
        location: null,
      );

      final imageData = await spoofEntry.readImage(
        rootFolder,
        firstEntry.images![0],
      );
      return imageData.bytes;
    });
