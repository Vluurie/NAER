import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/naer_utils/global_log.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate/isolate.dart';

class IsolateService {
  final int numberOfIsolates;
  LoadBalancer? _loadBalancer;

  IsolateService() : numberOfIsolates = Platform.numberOfProcessors {
    _initializeLoadBalancer();
  }

  Future<void> _initializeLoadBalancer() async {
    _loadBalancer ??=
        await LoadBalancer.create(numberOfIsolates, IsolateRunner.spawn);
  }

  Future<T> runTask<T>(FutureOr<T> Function(dynamic) task, dynamic arg) async {
    await _initializeLoadBalancer();
    return _loadBalancer!.run(task, arg);
  }

  Future<Map<int, List<String>>> distributeFilesAsync(
      List<String> files) async {
    return compute(_distributeFiles, files);
  }

  static Map<int, List<String>> _distributeFiles(List<String> files) {
    final int numberOfCores = Platform.numberOfProcessors;
    final Map<int, List<String>> distributedFiles = {};

    for (int i = 0; i < numberOfCores; i++) {
      distributedFiles[i] = [];
    }

    for (int i = 0; i < files.length; i++) {
      int coreIndex = i % numberOfCores;
      distributedFiles[coreIndex]!.add(files[i]);
    }

    return distributedFiles;
  }

  Future<void> runTasks(List<FutureOr<void> Function(dynamic)> tasks) async {
    await _initializeLoadBalancer();
    final taskFutures =
        tasks.map((task) => _loadBalancer!.run(task, null)).toList();
    await Future.wait(taskFutures);
  }

  void runInIsolate(Function function, List<dynamic> arguments) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
        isolateEntry, [function, arguments, receivePort.sendPort]);
    await receivePort.first;
  }

  Future<void> runInAwaitedIsolate(
      Function function, List<dynamic> arguments) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
        isolateEntry, [function, arguments, receivePort.sendPort]);
    await receivePort.first;
  }

  Future<T> runInAwaitedReturnIsolate<T>(
      Function function, List<dynamic> arguments) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
        _isolateEntryWithReturn, [function, arguments, receivePort.sendPort]);

    final result = await receivePort.first;
    if (result is T) {
      return result;
    } else {
      throw Exception('Unexpected result type: ${result.runtimeType}');
    }
  }

  static Future<void> isolateEntry(List<dynamic> args) async {
    final function = args[0] as Function;
    final arguments = args[1] as List<dynamic>;
    final sendPort = args[2] as SendPort;

    try {
      await Function.apply(function, arguments);
    } catch (e) {
      globalLog("Error: $e");
    } finally {
      sendPort.send(null);
    }
  }

  static Future<void> _isolateEntryWithReturn(List<dynamic> args) async {
    final function = args[0] as Function;
    final arguments = args[1] as List<dynamic>;
    final sendPort = args[2] as SendPort;

    try {
      final result = await Function.apply(function, arguments);
      sendPort.send(result);
    } catch (e) {
      sendPort.send(e);
    }
  }
}
