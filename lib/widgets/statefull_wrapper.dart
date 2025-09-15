import 'package:flutter/material.dart';

class StatefullWrapper<S extends ChangeNotifier> extends StatelessWidget {
  final S state;
  Widget? child;
  final bool isLoading;
  PreferredSizeWidget? appBar;
  StatefullWrapper({
    required this.state,
    this.child,
    this.isLoading = false,
    this.appBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Scaffold(
            appBar: appBar,
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : child,
          );
        });
  }
}
