import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Loads the dynamic library for the Windows platform.
/// The DLL `yax_to_xml.dll` should be in the same directory as the Dart executable.
final DynamicLibrary dylib = DynamicLibrary.open('yax_to_xml.dll');

/// Type definition for the `yax_file_to_xml_file` function in the Rust library.
/// This represents the function signature in C: `void yax_file_to_xml_file(const char* yaxFilePath, const char* xmlFilePath)`.
typedef YaxFileToXmlFileFunc = Void Function(
    Pointer<Utf8> yaxFilePath, Pointer<Utf8> xmlFilePath);

/// Dart function type corresponding to the Rust `yax_file_to_xml_file` function.
typedef YaxFileToXmlFile = void Function(
    Pointer<Utf8> yaxFilePath, Pointer<Utf8> xmlFilePath);

/// Looks up the `yax_file_to_xml_file` function in the dynamic library and assigns it to a Dart variable.
/// The function can then be called from Dart.
final YaxFileToXmlFile yaxFileToXmlFile = dylib
    .lookup<NativeFunction<YaxFileToXmlFileFunc>>('yax_file_to_xml_file')
    .asFunction();

/// Converts a YAX file to an XML file by calling the Rust function.
/// - `yaxFilePath`: The path to the input YAX file.
/// - `xmlFilePath`: The path to the output XML file.
///
/// This function performs the following steps:
/// 1. Converts the Dart strings `yaxFilePath` and `xmlFilePath` to C-style UTF-8 strings.
/// 2. Calls the `yax_file_to_xml_file` function from the Rust library.
/// 3. Frees the allocated memory for the C-style strings.
Future<void> convertYaxFileToXmlFile(
    String yaxFilePath, String xmlFilePath) async {
  // Convert Dart strings to C-style UTF-8 strings.
  final Pointer<Utf8> yaxFilePathPtr = yaxFilePath.toNativeUtf8();
  final Pointer<Utf8> xmlFilePathPtr = xmlFilePath.toNativeUtf8();

  // Call the Rust function.
  yaxFileToXmlFile(yaxFilePathPtr, xmlFilePathPtr);

  // Free the allocated memory.
  malloc.free(yaxFilePathPtr);
  malloc.free(xmlFilePathPtr);
}
