import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/providers/cache_entries.dart';
import 'package:journal/providers/image.dart';

final dayImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, DateTime>((ref, DateTime dt) async {
      final entries = await ref.watch(cacheEntriesProvider.future);

      final firstEntry = entries
          .where(
            (entry) =>
                DateUtils.isSameDay(entry.createdDate, dt) &&
                entry.images?.isNotEmpty == true,
          )
          .toList()
          .elementAtOrNull(0);
      if (firstEntry == null) return null;

      final imageData = await ref.watch(
        imageProvider(dt, firstEntry.images![0], QualityLevel.thumbnail).future,
      );
      return imageData;
    });
