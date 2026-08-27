import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:journal/image.dart';
import 'package:journal/logger.dart';
import 'package:journal/utils/file.dart';
import 'package:journal/utils/frontmatter.dart';

class Entry implements Comparable<Entry> {
  final String body;
  final DateTime datetime;
  final List<String> tags;
  final List<String> images;

  Entry({
    required this.body,
    required this.datetime,
    required this.tags,
    required this.images,
  });

  @override
  int compareTo(Entry other) {
    return datetime.compareTo(other.datetime);
  }

  Future<void> _moveImages(
    String rootFolder,
    List<String> images,
    DateTime oldDatetime,
    DateTime newDatetime,
  ) async {
    final oldEntryDirPath = parentPathFromDatetime(oldDatetime);
    final newEntryDirPath = parentPathFromDatetime(newDatetime);

    for (final image in images) {
      final oldImagePath = [...oldEntryDirPath, image];
      final newImagePath = [...newEntryDirPath, image];

      logger.d("moving image $image from $oldImagePath to $newImagePath");

      final imageBytes = await readFileBytes(rootFolder, oldImagePath);
      if (imageBytes == null) {
        logger.w("Couldn't find image at $oldImagePath when moving it.");
        continue;
      }

      await writeFileBytes(rootFolder, newImagePath, imageBytes, "image/xyz");
      await deleteFile(rootFolder, oldImagePath);
    }
  }

  Future<Entry> copyWith(
    String rootFolder, {
    String? body,
    DateTime? datetime,
    List<String>? tags,
    List<String>? images,
  }) async {
    final isSameDay = DateUtils.isSameDay(
      datetime ?? this.datetime,
      this.datetime,
    );
    if (!isSameDay) {
      final newImages = images ?? this.images;
      logger.w(
        "moving images because ${datetime ?? this.datetime}!=${this.datetime}",
      );
      await _moveImages(
        rootFolder,
        newImages,
        this.datetime,
        datetime ?? this.datetime,
      );
    }

    return Entry(
      body: body ?? this.body,
      datetime: datetime ?? this.datetime,
      tags: tags ?? this.tags,
      images: images ?? this.images,
    );
  }

  Future<void> write(String rootFolder) async {
    final path = pathFromDatetime(datetime);
    final content = addMdFrontmatter(body, {
      "tags": tags.join(","),
      "images": images.join(","),
    });

    await writeFileString(rootFolder, path, content, "text/markdown");
  }

  Future<void> delete(String rootFolder) async {
    final path = pathFromDatetime(datetime);
    await deleteFile(rootFolder, path);
  }

  Future<Entry> addImage(String rootFolder, XFile image, String name) async {
    final ext = path.extension(image.name);
    final imageName = name + ext;

    final entryPath = pathFromDatetime(datetime);
    final imagePath = [
      ...entryPath.sublist(0, entryPath.length - 1),
      imageName,
    ];

    logger.d("Adding image to entry at path $imagePath.");

    final imageBytes = await image.readAsBytes();

    await writeFileBytes(rootFolder, imagePath, imageBytes, "image/xyz");

    return copyWith(rootFolder, images: [...images, imageName]);
  }

  Future<Entry> removeImage(String rootFolder, String name) async {
    final entryPath = pathFromDatetime(datetime);
    final imagePath = [...entryPath.sublist(0, entryPath.length - 1), name];

    logger.d("Deleting image at path $imagePath");

    await deleteFile(rootFolder, imagePath);

    final newImages = images.where((image) => image != name).toList();

    return copyWith(rootFolder, images: newImages);
  }

  Future<ImageData> readImage(String rootFolder, String name) async {
    final entryPath = pathFromDatetime(datetime);
    final imagePath = [...entryPath.sublist(0, entryPath.length - 1), name];

    final bytes = await readFileBytes(rootFolder, imagePath);

    return ImageData(bytes: bytes, name: name);
  }

  static Future<Entry?> read(String datetimeString, String rootFolder) async {
    final datetime = DateTime.tryParse(datetimeString);
    if (datetime == null) return null;

    final path = pathFromDatetime(datetime);
    final content = await readFile(rootFolder.toString(), path);
    if (content == null) return null;

    return Entry.fromContent(content, datetime);
  }

  static Entry fromContent(String fileContent, DateTime datetime) {
    final (body, frontmatter) = parseMdFrontmatter(fileContent);
    final tagsString = frontmatter["tags"] ?? "";
    final imagesString = frontmatter["images"] ?? "";
    final tags = tagsString
        .split(",")
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    final images = imagesString
        .split(",")
        .map((img) => img.trim())
        .where((img) => img.isNotEmpty)
        .toSet()
        .toList();

    return Entry(body: body, datetime: datetime, tags: tags, images: images);
  }
}
