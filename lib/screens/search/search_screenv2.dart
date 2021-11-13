import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/backdrop.dart';

class SearchScreenv2 extends StatefulWidget {
  static const routeName = '/search-screenv2';

  @override
  _SearchScreenv2State createState() => _SearchScreenv2State();
}

class _SearchScreenv2State extends State<SearchScreenv2>
    with SingleTickerProviderStateMixin {
  static const ANIMATION_TIME = 200;

  late AnimationController controller;
  late AnimateIconController iconController;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ANIMATION_TIME),
      value: 1.0,
    );
    iconController = AnimateIconController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  bool get isPanelVisible {
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wyszukaj'),
        elevation: 0.0,
        actions: [
          AnimateIcons(
            startIconColor: Colors.white,
            endIconColor: Colors.white,
            startIcon: Icons.filter_alt,
            endIcon: Icons.close,
            controller: iconController,
            duration: Duration(milliseconds: ANIMATION_TIME),
            onEndIconPress: animateIconOnPress,
            onStartIconPress: animateIconOnPress,
          ),
        ],
      ),
      body: Backdrop(
        controller: controller,
      ),
    );
  }

  bool animateIconOnPress() {
    if (iconController.isStart()) {
      iconController.animateToEnd();
    } else if (iconController.isEnd()) {
      iconController.animateToStart();
    }
    // rozwinięcie / zawinięcie backdrop'u
    controller.fling(velocity: isPanelVisible ? -1.0 : 1.0);
    return true;
  }
}

// leading: new IconButton(
// onPressed: () {
// controller.fling(velocity: isPanelVisible ? -1.0 : 1.0);
// },
// icon: new AnimatedIcon(
// icon: AnimatedIcons.close_menu,
// progress: controller.view,
// ),
// ),
