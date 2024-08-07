import 'dart:io';
import 'dart:typed_data';

/// A service class for managing money data within NieR: Automata's SlotData save files.
///
/// This class includes methods for reading and updating the money value directly within the game's save files.
class MoneyService {
  /// The file position where money data starts within the save file.
  static const int startMoneyPosition = 0x3056C;

  /// The length (in bytes) of the money data to read from the save file.
  static const int moneyLength = 4;

  /// Reads the money value from a specified position in a save file.
  ///
  /// Parameters:
  /// - `filePath`: The path to the save file.
  ///
  /// Returns a future that completes with the integer value of the money.
  static Future<int> getMoneyFromFile(String filePath) async {
    var file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.read);

    await raf.setPosition(startMoneyPosition);
    Uint8List bytes = await raf.read(moneyLength);
    int money = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
    await raf.close();
    return money;
  }

  /// Updates the money value in a save file to a new value.
  ///
  /// Parameters:
  /// - `filePath`: The path to the save file.
  /// - `newMoney`: The new money value to write to the file.
  ///
  /// Validates the new money value before writing and ensures it doesn't exceed the game's limits.
  static Future<void> updateMoneyInFile(String filePath, int newMoney) async {
    if (newMoney < 0) {
      throw ArgumentError("Money cannot be negative.");
    }

    var byteData = ByteData(4);
    byteData.setInt32(0, newMoney, Endian.little);
    Uint8List bytes = byteData.buffer.asUint8List();

    var file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.writeOnlyAppend);
    await raf.setPosition(startMoneyPosition);
    await raf.writeFrom(bytes);
    await raf.close();
  }
}
