import 'dart:isolate';

import 'package:args/args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xml/xml.dart' as xml;

part 'main_data_container.freezed.dart';

@freezed
class MainData with _$MainData {
  const factory MainData({
    required final Map<String, dynamic> argument,
    final OptionIdentifier? sortedEnemyGroupsIdentifierMap,
    final bool? isManagerFile,
    required final String output,
    required final ArgResults args,
    required final SendPort sendPort,
    final bool? backUp,
    final bool? isBalanceMode,
    final bool? hasDLC,
    required final bool isAddition,
  }) = _MainData;
}

@freezed
class NierCliArgs with _$NierCliArgs {
  const factory NierCliArgs({
    required final List<String> arguments,
    final bool? isManagerFile,
    required final SendPort sendPort,
    final bool? backUp,
    final bool? isBalanceMode,
    final bool? hasDLC,
    required final bool isAddition,
  }) = _NierCliArgs;
}

@freezed
class EnemyEntityObjectAction with _$EnemyEntityObjectAction {
  const factory EnemyEntityObjectAction({
    required final xml.XmlElement objIdElement,
    required final Map<String, List<String>> userSelectedEnemyData,
    required final String enemyLevel,
    required final bool isSpawnActionTooSmall,
    @Default(false) final bool handleLevels,
    @Default(false) final bool randomizeAndSetValues,
  }) = _EnemyEntityObjectAction;
}

@freezed
class OptionIdentifier with _$OptionIdentifier {
  const factory OptionIdentifier({
    required final String value,
  }) = _OptionIdentifier;

  /// Case when no enemies or categories were selected
  static const OptionIdentifier all = OptionIdentifier(value: 'ALL');

  /// Case when custom setups were made
  static const OptionIdentifier customSelected = OptionIdentifier(value: 'CUSTOM_SELECTED');

  /// Case when only stats are selected without any active options
  static const OptionIdentifier statsOnly = OptionIdentifier(value: 'STATS_ONLY');
}

@freezed
class ExtractedFiles with _$ExtractedFiles {
  const factory ExtractedFiles({
    required final List<YaxFile> yaxFiles,
    required final List<XmlFile> xmlFiles,
    required final List<PakFolder> pakFolders,
    required final List<DatFolder> datFolders,
    required final List<CpkExtractedFolder> cpkExtractedFolders,
  }) = _ExtractedFiles;
}

@freezed
class YaxFile with _$YaxFile {
  const factory YaxFile({required final String path}) = _YaxFile;
}

@freezed
class XmlFile with _$XmlFile {
  const factory XmlFile({required final String path}) = _XmlFile;
}

@freezed
class PakFolder with _$PakFolder {
  const factory PakFolder({required final String path}) = _PakFolder;
}

@freezed
class DatFolder with _$DatFolder {
  const factory DatFolder({required final String path}) = _DatFolder;
}

@freezed
class CpkExtractedFolder with _$CpkExtractedFolder {
  const factory CpkExtractedFolder({required final String path}) = _CpkExtractedFolder;
}

