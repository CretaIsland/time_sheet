import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

class MyFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool doFlip;
  final void Function() onInitEnd;
  const MyFlipCard(
      {super.key,
      required this.front,
      required this.back,
      required this.doFlip,
      required this.onInitEnd});

  @override
  State<MyFlipCard> createState() => _MyFlipCardState();
}

class _MyFlipCardState extends State<MyFlipCard> {
  FlipCardController controller = FlipCardController();

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //logger.finest('PostFrame invoded ${widget.doFlip}');
      if (widget.doFlip) {
        controller.toggleCard();
        widget.onInitEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: controller,
      flipOnTouch: false,
      fill: Fill.fillBack,
      direction: FlipDirection.VERTICAL,
      front: widget.front,
      back: widget.back,
    );
  }
}
