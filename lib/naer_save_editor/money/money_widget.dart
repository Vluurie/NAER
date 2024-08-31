import 'dart:async';

import 'package:NAER/naer_save_editor/money/money_service.dart';
import 'package:NAER/naer_ui/setup/snackbars.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoneyWidget extends ConsumerStatefulWidget {
  final String filePath;

  const MoneyWidget({super.key, required this.filePath});

  @override
  MoneyWidgetState createState() => MoneyWidgetState();
}

class MoneyWidgetState extends ConsumerState<MoneyWidget>
    with TickerProviderStateMixin {
  int _money = 0;
  final TextEditingController _moneyController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _opacityController;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _colorController;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));

    _colorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _colorAnimation =
        ColorTween(begin: Colors.blueGrey[900], end: Colors.green[400]).animate(
            CurvedAnimation(parent: _colorController, curve: Curves.easeIn))
          ..addListener(() {
            setState(() {});
          });

    _getMoney();
  }

  Future<void> _getMoney() async {
    int money = await MoneyService.getMoneyFromFile(widget.filePath);
    setState(() {
      _money = money;
    });
  }

  Future<void> _updateMoney(final int newMoneyAmount) async {
    if (newMoneyAmount >= 1 && newMoneyAmount <= 9999999) {
      await MoneyService.updateMoneyInFile(widget.filePath, newMoneyAmount);
      unawaited(
          _controller.forward().then((final value) => _controller.reverse()));
      unawaited(_opacityController
          .forward()
          .then((final _) => _opacityController.reverse()));
      unawaited(_colorController
          .forward()
          .then((final _) => _colorController.reverse()));
      await _getMoney();
    } else {
      SnackBarHandler.showSnackBar(
        context,
        ref,
        'Please enter a valid amount (1 - 9999999)',
        SnackBarType.info,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _opacityController.dispose();
    _colorController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shadowColor: AutomatoThemeColors.bright(ref),
            color: AutomatoThemeColors.darkBrown(ref),
            elevation: 20.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Note: Changes are directly modified and saved.',
                      style:
                          TextStyle(color: AutomatoThemeColors.textColor(ref)),
                    ),
                  ),
                  Text('Your Money: $_money',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AutomatoThemeColors.primaryColor(ref))),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_scaleAnimation, _opacityAnimation, _colorAnimation]),
                    builder: (final context, final child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text('$_money',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: AutomatoThemeColors.saveZone(ref))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _moneyController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        labelText: 'Enter new money amount',
                        labelStyle: TextStyle(
                            color: AutomatoThemeColors.textColor(ref)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AutomatoThemeColors.textColor(ref)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AutomatoThemeColors.textColor(ref)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only allow numbers
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: AutomatoThemeColors.darkBrown(ref),
                        backgroundColor: AutomatoThemeColors.primaryColor(ref)),
                    onPressed: () {
                      final int newMoneyAmount =
                          int.tryParse(_moneyController.text) ?? -1;
                      _updateMoney(newMoneyAmount);
                      _moneyController.clear();
                    },
                    child: const Text('Update Money'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
