import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate/isolate.dart';

class IsolateService {
  final int numberOfIsolates;
  LoadBalancer? _loadBalancer;
  final List<IsolateRunner> _isolateRunners = [];
  final List<IsolateRunner> _availableRunners = [];
  bool _isInitialized = false;

  IsolateService({final bool autoInitialize = false})
      : numberOfIsolates = _determineNumberOfIsolates() {
    if (autoInitialize) {
      _initializeLoadBalancer();
    }
  }

  static int _determineNumberOfIsolates() {
    final int cores = Platform.numberOfProcessors;
    return cores > 8 ? 8 : cores; // flutter only allow isolates to 8
  }

  Future<void> _initializeLoadBalancer() async {
    if (!_isInitialized) {
      _loadBalancer = await LoadBalancer.create(numberOfIsolates, () async {
        final runner = await _getOrCreateRunner();
        return runner;
      });
      _isInitialized = true;
    }
  }

  Future<void> initialize({final bool forceReinitialize = false}) async {
    if (!_isInitialized || forceReinitialize) {
      await _initializeLoadBalancer();
    }
  }

  Future<T> runTask<T>(
      final FutureOr<T> Function(dynamic) task, final dynamic arg) async {
    await _initializeLoadBalancer();
    return _loadBalancer!.run(task, arg);
  }

  Future<Map<int, List<String>>> distributeFilesAsync(
      final List<String> files) async {
    return compute(_distributeFiles, files);
  }

  static Map<int, List<String>> _distributeFiles(final List<String> files) {
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

  Future<void> runTasks(
      final List<FutureOr<void> Function(dynamic)> tasks) async {
    await _initializeLoadBalancer();
    final taskFutures =
        tasks.map((final task) => _loadBalancer!.run(task, null)).toList();
    await Future.wait(taskFutures);
  }

  Future<void> runInIsolate(
      final Function function, final List<dynamic> arguments) async {
    final receivePort = ReceivePort();
    final runner = await _getOrCreateRunner();
    await runner.run(isolateEntry, [function, arguments, receivePort.sendPort]);
    _availableRunners.add(runner);
    await receivePort.first;
  }

  Future<void> runInAwaitedIsolate(
      final Function function, final List<dynamic> arguments) async {
    final receivePort = ReceivePort();
    final runner = await _getOrCreateRunner();
    await runner.run(isolateEntry, [function, arguments, receivePort.sendPort]);
    _availableRunners.add(runner);
    await receivePort.first;
  }

  Future<IsolateRunner> _getOrCreateRunner() async {
    // runner avaliable??
    if (_availableRunners.isNotEmpty) {
      return _availableRunners.removeLast();
    } else {
      // no, create one
      final runner = await IsolateRunner.spawn();
      _isolateRunners.add(runner);
      return runner;
    }
  }

  static Future<void> isolateEntry(final List<dynamic> args) async {
    final function = args[0] as Function;
    final arguments = args[1] as List<dynamic>;
    final sendPort = args[2] as SendPort;

    try {
      await Function.apply(function, arguments);
    } catch (e, stackTrace) {
      ExceptionHandler().handle(
        e,
        stackTrace,
        extraMessage: "Error occurred during isolate entry execution",
      );
    } finally {
      sendPort.send(null);
    }
  }

  Future<void> killAllIsolates() async {
    for (var runner in _isolateRunners) {
      await runner.close();
    }
    _isolateRunners.clear();
    _availableRunners.clear();
  }

  Future<void> cleanup() async {
    await _loadBalancer?.close();
    await killAllIsolates();
    _loadBalancer = null;
    _isInitialized = false;
  }
}
