import 'package:flutter/material.dart';

class NotifierScaffold<S extends ChangeNotifier> extends StatelessWidget {
  final S state;
  bool isLoading;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget Function(BuildContext context, S state) builder;

  NotifierScaffold({
    super.key,
    required this.state,
    required this.builder,
    this.appBar,
    this.floatingActionButton,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final loading = isLoading;
        return Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : builder(context, state),
        );
      },
    );
  }
}
