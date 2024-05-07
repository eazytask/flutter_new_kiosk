import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
  }) : super(key: key);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWidgetState extends State<AppBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  // void resetController() {
  //   if (widget.resetController != null)
  //     widget.resetController!(_controller);
  // }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1,
      duration: const Duration(milliseconds: 600),
    );
    animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    animation.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppBarWidget oldWidget) {

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    return AppBar(
      elevation: 0,
      title: widget.title,
      leading: widget.leading,
      centerTitle: true,
      bottom: widget.bottom,
      actions: widget.actions,
    );
  }
}
