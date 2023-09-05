import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final rssHeight = StateProvider<double>((ref) {
  return .45.sh;
});

// scrollable sheet with riverpod dependant function
class RiverSSheet extends ConsumerWidget {
  const RiverSSheet({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: ref.watch(rssHeight),
        child: child);
  }
}

class CSExpand extends ConsumerWidget {
  const CSExpand({
    Key? key,
    required this.child,
    required this.expandZero,
    required this.expandEnd,
  }) : super(key: key);
  final Widget child;

  final double expandZero;
  final double expandEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /// y(x) such that y(.2) = 0 and y(.8) = 1
    /// y = (x - .2) + (2/3)(x-.2)
    ///
    double rssh = ref.watch(rssHeight);
    double xx = (rssh / 1.sh);

    /// y(x) such that y(A) = 0 and y(B) = 1
    ///
    /// y = (1/(B-A))x - (A/(B-A))

    double yy = (1 / (expandEnd - expandZero)) * xx -
        (expandZero / (expandEnd - expandZero));

    return Transform(
        transform: Matrix4.identity()
          ..scale(
              1.0,
              (yy > 1
                  ? 1
                  : yy < 0
                  ? 0
                  : yy)),
        alignment: Alignment.center,
        child: child);
  }
}

class CSShrink extends ConsumerWidget {
  const CSShrink({
    Key? key,
    required this.child,
    required this.shrinkZero,
    required this.shrinkEnd,
  }) : super(key: key);
  final Widget child;

  final double shrinkZero;
  final double shrinkEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    double rssh = ref.watch(rssHeight);
    double xx = (rssh / 1.sh);

    /// y(x) such that y(A) = 1 and y(B) = 0
    ///
    /// y = -(1/(B-A))x + (A/(B-A)) + 1

    double yy = (-(1 / (shrinkEnd - shrinkZero)) * xx) +
        (shrinkZero / (shrinkEnd - shrinkZero)) +
        1;

    return Transform(
        transform: Matrix4.identity()
          ..scale(
              1.0,
              (yy > 1
                  ? 1
                  : yy < 0
                  ? 0
                  : yy)),
        alignment: Alignment.center,
        child: child);
  }
}

class RPSDS extends ConsumerStatefulWidget {
  const RPSDS({Key? key})
      : super(key: key);

  @override
  RPSDSState createState() => RPSDSState();
}

class RPSDSState extends ConsumerState<RPSDS> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    ref.read(rssHeight.notifier).state = .45.sh;
    scrollController.dispose();
    super.dispose();
  }

  double sheetHeight = 0;
  double minSheetHeight = 0;
  double maxSheetHeight = 0;
  double startingSheetHeight = 0;

  double lastScroll = 0;
  double nextScroll = 0;

  bool reposInProg = false;

  @override
  void initState() {
    sheetHeight = .45.sh;
    startingSheetHeight = sheetHeight;
    minSheetHeight = .2.sh;
    maxSheetHeight = .8.sh;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          Expanded(
              child: Stack(children: [

                Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: Colors.orange,
                  child: Center(child:Text("BODY")),
                ),

                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child:Container(color: Colors.blue,
                        height: .1.sh,
                        child: Text("HEAD")
                        ,)),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RiverSSheet(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12.w),
                                    topLeft: Radius.circular(12.w)),
                                color: Colors.white),
                            child:

                            /// not working
                            // GestureDetector(
                            //   onVerticalDragUpdate: (DragUpdateDetails dud){
                            //     print("drag update");
                            //   },
                            Listener(
                                onPointerUp: (PointerUpEvent pue) {
                                  var rssh = ref.watch(rssHeight);

                                  // snap to mid or bottom
                                  if (rssh < startingSheetHeight) {
                                    if ((startingSheetHeight - rssh) <
                                        (rssh - minSheetHeight)) {
                                      ref.read(rssHeight.notifier).state =
                                          startingSheetHeight;
                                    } else {
                                      ref.read(rssHeight.notifier).state =
                                          minSheetHeight;
                                    }
                                  }

                                  // snap to top
                                  if (rssh > startingSheetHeight) {
                                    if (maxSheetHeight - rssh > 151.h) {
                                      ref.read(rssHeight.notifier).state =
                                          startingSheetHeight;
                                    }
                                    if (maxSheetHeight - rssh < 151.h) {
                                      ref.read(rssHeight.notifier).state =
                                          maxSheetHeight;
                                    }
                                  }
                                },
                                onPointerMove: (PointerMoveEvent opm) {
                                  var rssh = ref.watch(rssHeight);

                                  // swiped down
                                  if (opm.delta.dy > 0) {
                                    if (scrollController.position.pixels == 0) {
                                      if (rssh > minSheetHeight) {
                                        if (scrollController.offset < 1 ||
                                            scrollController.offset > -1) {
                                          ref.read(rssHeight.notifier).state -=
                                              opm.delta.dy;
                                        }
                                      }
                                    }

                                    if (rssh == maxSheetHeight &&
                                        scrollController.position.pixels < 15) {
                                      ref.read(rssHeight.notifier).state -=
                                          opm.delta.dy;
                                    }
                                  }
                                  // swiped up
                                  else if (opm.delta.dy < 0 &&
                                      (sheetHeight < maxSheetHeight)) {
                                    if (rssh <= maxSheetHeight) {
                                      ref.read(rssHeight.notifier).state -=
                                          opm.delta.dy;
                                    }
                                  }
                                },
                                child: ListView(
                                    controller: scrollController,
                                    physics: ref.watch(rssHeight) < maxSheetHeight
                                        ? const NeverScrollableScrollPhysics()
                                        : const ScrollPhysics(),
                                    //   // physics: const BouncingScrollPhysics(),
                                    children: [
                                      // Expanded(child:Container(height: .3.sh, color: Colors.purple,)),
                                      //     Container(height: .3.sh, color: Colors.red,)
                                      Container(
                                          height: 88.h,
                                          color: Colors.purple, ),
                                      CSShrink(
                                        // snapOffset: .45,
                                          shrinkZero: .2,
                                          shrinkEnd: .45,
                                          child: Container(
                                            color: Colors.teal,
                                          )),
                                       CSExpand(
                                        expandZero: .2,
                                        expandEnd: .45,
                                       child:Container(
                                         color: Colors.deepPurple,
                                         height: .1.sh,
                                       )
                                      ),
                                      CSExpand(
                                        expandZero: .45,
                                        expandEnd: .8,
                                        // snapOffset: .8,
                                        child: Container(
                                          height: .3.sh,
                                          color: Colors.blueGrey[700],
                                        )
                                      ),
                                    ])))))
              ]))
        ]));
  }
}
