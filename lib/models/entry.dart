import "dart:typed_data";

import "package:flutter/material.dart";
import "package:journal/utils/location.dart";
import "package:journal/utils/yaml.dart";
import "package:journal/logger.dart";
import "package:journal/utils/file.dart";
import "package:journal/utils/frontmatter.dart";
import "package:saf/saf.dart";
import "package:saf_stream/saf_stream.dart";
import "package:yaml/yaml.dart";

class Entry implements Comparable<Entry> {
  final String body;
  final DateTime datetime;
  final List<String> tags;
  final List<String> images;
  final Location? location;

  Entry({
    required this.body,
    required this.datetime,
    required this.tags,
    required this.images,
    required this.location,
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
    Saf saf,
    SafStream safStream,
  ) async {
    final oldEntryDirPath = parentPathFromDatetime(oldDatetime);
    final newEntryDirPath = parentPathFromDatetime(newDatetime);

    for (final image in images) {
      final oldImagePath = [...oldEntryDirPath, image];
      final newImagePath = [...newEntryDirPath, image];

      logger.d("moving image $image from $oldImagePath to $newImagePath");

      final imageBytes = await readFileBytes(
        rootFolder,
        oldImagePath,
        saf,
        safStream,
      );
      if (imageBytes == null) {
        logger.w("Couldn't find image at $oldImagePath when moving it.");
        continue;
      }

      await writeFileBytes(
        rootFolder,
        newImagePath,
        imageBytes,
        "image/xyz",
        saf,
        safStream,
      );
      await deleteFile(rootFolder, oldImagePath, saf);
    }
  }

  Future<Entry> copyWith(
    String rootFolder,
    Saf saf,
    SafStream safStream, {
    String? body,
    DateTime? datetime,
    List<String>? tags,
    List<String>? images,
    Location? location,
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
        saf,
        safStream,
      );
    }

    return Entry(
      body: body ?? this.body,
      datetime: datetime ?? this.datetime,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      location: location ?? this.location,
    );
  }

  Future<void> write(String rootFolder, Saf saf, SafStream safStream) async {
    final path = pathFromDatetime(datetime);

    final Map<String, dynamic> yamlData = {"tags": tags, "images": images};

    if (location != null) {
      yamlData["location"] = [location!.latitude, location!.longitude];
      if (location!.name != null) {
        yamlData["place_name"] = location!.name;
      }
      if (location!.displayName != null) {
        yamlData["address"] = location!.displayName;
      }
    }

    final content = addMdFrontmatter(body, yamlData);

    await writeFileString(
      rootFolder,
      path,
      content,
      "text/markdown",
      saf,
      safStream,
    );
  }

  Future<void> delete(String rootFolder, Saf saf, SafStream safStream) async {
    final path = pathFromDatetime(datetime);
    final folderPath = parentPathFromDatetime(datetime);
    await deleteFile(rootFolder, path, saf);
    for (final image in images) {
      final imagePath = [...folderPath, image];
      await deleteFile(rootFolder, imagePath, saf);
    }
  }

  Future<Entry> addImage(
    String rootFolder,
    Uint8List bytes,
    String name,
    String ext,
    Saf saf,
    SafStream safStream,
  ) async {
    final fullName = name + ext;

    final entryPath = pathFromDatetime(datetime);
    final imagePath = [...entryPath.sublist(0, entryPath.length - 1), fullName];

    logger.d("Adding image to entry at path $imagePath.");

    await writeFileBytes(
      rootFolder,
      imagePath,
      bytes,
      "image/$ext",
      saf,
      safStream,
    );

    return copyWith(rootFolder, saf, safStream, images: [...images, fullName]);
  }

  Future<Entry> removeImage(
    String rootFolder,
    String name,
    Saf saf,
    SafStream safStream,
  ) async {
    final entryPath = pathFromDatetime(datetime);
    final imagePath = [...entryPath.sublist(0, entryPath.length - 1), name];

    logger.d("Deleting image at path $imagePath");

    await deleteFile(rootFolder, imagePath, saf);

    final newImages = images.where((image) => image != name).toList();

    return copyWith(rootFolder, saf, safStream, images: newImages);
  }

  static Future<Entry?> read(
    String datetimeString,
    String rootFolder,
    Saf saf,
    SafStream safStream,
  ) async {
    final datetime = DateTime.tryParse(datetimeString);
    if (datetime == null) return null;

    final path = pathFromDatetime(datetime);
    final content = await readFile(rootFolder.toString(), path, saf, safStream);
    if (content == null) return null;

    return Entry.fromContent(content, datetime);
  }

  static Entry fromContent(String fileContent, DateTime datetime) {
    final (body, frontmatter) = parseMdFrontmatter(fileContent);
    final tags = dynamicYamlToList<String>(frontmatter?["tags"] ?? YamlList());
    final images = dynamicYamlToList<String>(
      frontmatter?["images"] ?? YamlList(),
    );
    final location = frontmatter != null ? locationFromYaml(frontmatter) : null;

    return Entry(
      body: body,
      datetime: datetime,
      tags: tags,
      images: images,
      location: location,
    );
  }
}
