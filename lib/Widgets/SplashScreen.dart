import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../FadeIn.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  Animation<Offset> animation;
  AnimationController controllerLeft;
  AnimationController controllerMid;
  AnimationController controllerRight;

  imageRotation(BuildContext context, double angle, Offset offset){
    return Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: angle,
          child: Image.asset(
            'assets/shard.png',
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        )
    );
  }

  startFromOffset(double x, double y, AnimationController controller){
    return Tween<Offset>(
        begin: Offset(x, y),
        end: Offset(0, 0)
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, 1.0, curve: Curves.linear),
    ));
  }

  @override
  void dispose() {
    super.dispose();

  }

  @override
  void initState() {
    super.initState();
    controllerLeft = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    controllerMid = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    controllerRight = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    controllerLeft.forward();
    Future.delayed(Duration(milliseconds: 300), (){
      controllerMid.forward();
    });
    Future.delayed(Duration(milliseconds: 600), (){
      controllerRight.forward();
    });
    /*
     */
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Stack(
              children: [
                SlideTransition(
                  position: startFromOffset(
                    -1.5, -1.5,
                    controllerLeft,
                  ),
                  child: imageRotation(context, -math.pi/4, Offset(-13.0, 0.0)),
                ),
                SlideTransition(
                  position: startFromOffset(
                    0, -1.5,
                    controllerMid,
                  ),
                  child: imageRotation(context, 0, Offset(0.0, -25.0)),
                ),
                SlideTransition(
                  position: startFromOffset(
                    1.5, -1.5,
                    controllerRight,
                  ),
                  child: imageRotation(context, math.pi/4, Offset(13.0, 0.0)),
                ),
              ],
            ),
            FadeIn(
              duration: 1500,
              child: Text(
                "StudyBuddy",
                style: TextStyle(
                  fontFamily: 'Langar',
                  fontSize: 30.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
