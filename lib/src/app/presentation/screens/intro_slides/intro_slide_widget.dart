import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../controllers/intro_slides/intro_slide_model.dart';

class IntroSlideWidget extends StatefulWidget {
  const IntroSlideWidget({super.key});

  @override
  _IntroSlideWidgetState createState() => _IntroSlideWidgetState();
}

class _IntroSlideWidgetState extends State<IntroSlideWidget> {
  final controller = PageController();
  bool showSwipePrompt = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final isLastPage =
          controller.page!.round() == 3; // The index of the last page is 3
      if (showSwipePrompt == isLastPage) {
        setState(() {
          showSwipePrompt = !isLastPage;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final introSlideModel =
        Provider.of<IntroSlideModel>(context, listen: false); // Define it here
    double bottomPosition = MediaQuery.of(context).size.height / 8;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (controller.page!.round() == 3) {
            introSlideModel.navigateToQuiz(context);
          } else {
            controller.nextPage(
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeIn,
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.8, 0.5),
              radius: 3,
              colors: [
                kPurpleColor,
                kPrimaryAccentColor,
                // Other gradient colors...
              ],
            ),
          ),
          child: Stack(
            children: [
              PageView.builder(
                //TODO: FONT > Lato
                controller: controller,
                itemCount: introSlideModel.slides.length + 1,
                itemBuilder: (context, index) {
                  if (index < introSlideModel.slides.length) {
                    return FadeInSlide(text: introSlideModel.slides[index]);
                  } else {
                    return const LastSlide();
                  }
                },
              ),
              if (showSwipePrompt)
                Positioned(
                  bottom: bottomPosition,
                  left: 0,
                  right: 0,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tap or Swipe",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!showSwipePrompt)
                Positioned(
                  bottom: bottomPosition,
                  left: 0,
                  right: 0,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Takes 2 minutes or less!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeInSlide extends StatelessWidget {
  final String text;

  const FadeInSlide({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FadeIn(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w100,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class LastSlide extends StatelessWidget {
  const LastSlide({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of IntroSlideModel
    final introSlideModel =
        Provider.of<IntroSlideModel>(context, listen: false);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Start discovering your personality!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                fontSize: 32,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPadding4),
            child: Row(
              children: [
                Expanded(
                  child: MirrorElevatedButton(
                    onPressed: () {
                      introSlideModel
                          .navigateToQuiz(context); // Use the instance here
                    },
                    child: const Text("Take the quiz >",
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
