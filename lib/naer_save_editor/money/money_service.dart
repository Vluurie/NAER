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

  static Future<int> getMoneyFromFile(final String filePath) async {
    var file = File(filePath);
    RandomAccessFile raf = await file.open();

    await raf.setPosition(startMoneyPosition);
    Uint8List bytes = await raf.read(moneyLength);
    int money = ByteData.view(bytes.buffer).getInt32(0, Endian.little);
    await raf.close();
    return money;
  }

  static Future<void> updateMoneyInFile(
      final String filePath, final int newMoney) async {
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
