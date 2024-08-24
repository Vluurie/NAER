import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';

/// Loads the dynamic library for the platform.
/// The DLL `extract_dat_files.dll` should be in the same directory as the Dart executable.
final DynamicLibrary dylib = DynamicLibrary.open('extract_dat_files.dll');

typedef ExtractDatFilesFFIFunc = Pointer<Utf8> Function(Pointer<Utf8> datPath,
    Pointer<Utf8> extractDir, Uint8 shouldExtractPakFiles);

typedef ExtractDatFilesFFI = Pointer<Utf8> Function(
    Pointer<Utf8> datPath, Pointer<Utf8> extractDir, int shouldExtractPakFiles);

final ExtractDatFilesFFI extractDatFilesFFI = dylib
    .lookup<NativeFunction<ExtractDatFilesFFIFunc>>('extract_dat_files_ffi')
    .asFunction();

/// Extracts files from a DAT file by calling the Rust function.
/// - `datFilePath`: The path to the input DAT file.
/// - `extractDirPath`: The path to the directory where extracted files will be saved.
/// - `shouldExtractPakFiles`: Whether to extract PAK files.
///
/// This function performs the following steps:
/// 1. Converts the Dart strings `datFilePath` and `extractDirPath` to C-style UTF-8 strings.
/// 2. Calls the `extract_dat_files_ffi` function from the Rust library.
/// 3. Converts the returned C-style UTF-8 string to a Dart string.
/// 4. Frees the allocated memory for the C-style strings and the returned result.
/// 5. Parses the JSON result to get a list of extracted file paths.
Future<List<String>> extractDatFiles(String datFilePath, String extractDirPath,
    bool shouldExtractPakFiles) async {
  final Pointer<Utf8> datFilePathPtr = datFilePath.toNativeUtf8();
  final Pointer<Utf8> extractDirPathPtr = extractDirPath.toNativeUtf8();

  try {
    // Call the Rust function.
    final Pointer<Utf8> resultPtr = extractDatFilesFFI(
        datFilePathPtr, extractDirPathPtr, shouldExtractPakFiles ? 1 : 0);

    if (resultPtr == nullptr) {
      throw Exception('Error extracting DAT files.');
    }

    final String resultStr = resultPtr.toDartString();

    final List<dynamic> files = jsonDecode(resultStr);
    return files.cast<String>();
  } finally {
    malloc.free(datFilePathPtr);
    malloc.free(extractDirPathPtr);
  }
}
