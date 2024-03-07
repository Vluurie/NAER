import 'package:flutter/material.dart';
import 'package:NAER/custom_naer_ui/mod__ui/metadata_form.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
import 'package:provider/provider.dart';
import 'package:NAER/custom_naer_ui/drag_n_drop.dart';
import 'package:NAER/custom_naer_ui/mod__ui/mod_loader_widget.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';

class SecondPage extends StatefulWidget {
  final CLIArguments cliArguments;

  const SecondPage({super.key, required this.cliArguments});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _modLoaderWidgetOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _modLoaderWidgetOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMetadataFormPopup() {
    final modStateManager =
        Provider.of<ModStateManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: MetadataForm(
              cliArguments: widget.cliArguments,
              modStateManager: modStateManager),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modStateManager =
        Provider.of<ModStateManager>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Features'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _modLoaderWidgetOpacity,
              duration: const Duration(milliseconds: 500),
              child: ModLoaderWidget(
                cliArguments: widget.cliArguments,
                modStateManager: modStateManager,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).size.height / 2,
            child: DragDropWidget(cliArguments: widget.cliArguments),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMetadataFormPopup,
        tooltip: 'Add Metadata',
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        backgroundColor: const Color.fromARGB(255, 0, 217, 255),
        hoverColor: const Color.fromARGB(255, 0, 255, 0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
