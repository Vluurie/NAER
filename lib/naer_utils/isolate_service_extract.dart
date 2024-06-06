import 'dart:async';
import 'dart:isolate';
import 'dart:io';

///TODO STILL IN WIP AND TESTING

class ExtractIsolateService {
  late final int numberOfIsolates;
  final Map<int, ExtractIsolateStatistics> isolateStats = {};

  ExtractIsolateService() {
    numberOfIsolates = Platform.numberOfProcessors;
    for (var i = 0; i < numberOfIsolates; i++) {
      isolateStats[i] = ExtractIsolateStatistics();
    }
  }

  Future<List<List<String>>> runTasks(
      List<FutureOr<List<String>> Function()> tasks) async {
    final List<Isolate> isolates = [];
    final List<ReceivePort> receivePorts = [];
    final List<SendPort> sendPorts = [];
    final List<Completer<void>> completers =
        List.generate(numberOfIsolates, (_) => Completer<void>());

    final results = <List<String>>[];

    for (var i = 0; i < numberOfIsolates; i++) {
      final receivePort = ReceivePort();
      receivePorts.add(receivePort);

      print('Spawning isolate $i');
      final isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
      isolates.add(isolate);

      receivePort.listen((message) {
        if (message is SendPort) {
          print('Isolate $i SendPort received');
          sendPorts.add(message);
          if (sendPorts.length == numberOfIsolates) {
            _distributeTasks(sendPorts, tasks);
          }
        } else if (message == 'done') {
          print('Isolate $i completed its tasks');
          completerComplete(completers[i]);
        } else if (message is List<ExtractIsolateTaskReport>) {
          _updateStatistics(i, message);
        } else if (message is List<String>) {
          results.add(message);
        }
      });
    }

    await Future.wait(completers.map((c) => c.future));

    for (var i = 0; i < numberOfIsolates; i++) {
      receivePorts[i].close();
      isolates[i].kill(priority: Isolate.immediate);
      print('Isolate $i killed');
    }

    _printStatistics();

    return results;
  }

  void _distributeTasks(
      List<SendPort> sendPorts, List<FutureOr<List<String>> Function()> tasks) {
    final int totalTasks = tasks.length;
    final int totalIsolates = sendPorts.length;

    if (totalTasks <= totalIsolates) {
      for (var i = 0; i < totalTasks; i++) {
        print('Sending 1 task to isolate $i');
        sendPorts[i].send([tasks[i]]);
      }
    } else {
      final tasksPerIsolate = (totalTasks / totalIsolates).ceil();
      for (var i = 0; i < totalIsolates; i++) {
        final start = i * tasksPerIsolate;
        final end = start + tasksPerIsolate > totalTasks
            ? totalTasks
            : start + tasksPerIsolate;
        final tasksSubset = tasks.sublist(start, end);

        print('Sending ${tasksSubset.length} tasks to isolate $i');
        sendPorts[i].send(tasksSubset);
      }
    }
  }

  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is List<FutureOr<List<String>> Function()>) {
        final taskReports = <ExtractIsolateTaskReport>[];
        final results = <String>[];
        print('Isolate received ${message.length} tasks');
        for (var task in message) {
          final startTime = DateTime.now();
          try {
            final result = await task();
            results.addAll(result);
          } catch (e) {
            print('Error in task: $e');
          }
          final endTime = DateTime.now();
          taskReports.add(ExtractIsolateTaskReport(startTime, endTime));
        }
        mainSendPort.send(results);
        mainSendPort.send(taskReports);
        mainSendPort.send('done');
        print('Isolate finished tasks and sent done message');
      }
    });
  }

  void _updateStatistics(
      int isolateIndex, List<ExtractIsolateTaskReport> taskReports) {
    final stats = isolateStats[isolateIndex]!;
    for (var report in taskReports) {
      stats.taskCount++;
      stats.totalTime += report.endTime.difference(report.startTime);
    }
  }

  void _printStatistics() {
    for (var i = 0; i < numberOfIsolates; i++) {
      final stats = isolateStats[i]!;
      print(
          'Isolate $i - Task Count: ${stats.taskCount}, Total Time: ${stats.totalTime.inMilliseconds} ms');
    }
  }

  Map<int, List<String>> distributeFiles(List<String> files) {
    final int numberOfCores = numberOfIsolates;
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

  void completerComplete(Completer<void> completer) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

class ExtractIsolateStatistics {
  int taskCount = 0;
  Duration totalTime = Duration.zero;
}

class ExtractIsolateTaskReport {
  final DateTime startTime;
  final DateTime endTime;

  ExtractIsolateTaskReport(this.startTime, this.endTime);
}
