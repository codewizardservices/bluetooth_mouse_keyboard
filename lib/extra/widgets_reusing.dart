import 'package:flutter/material.dart';

enum MessageStatus { success, failed, info }

const Color primaryColor = Color(0xFF2850E7);
const Color primaryColor1 = Color(0xffe040fb);
const Color accentColorRed = Color(0xFFC93B38);
const Color primaryColor1Dim = Color(0xffdfb3e7);
const Color primaryColorDim = Color(0xFFA6B5EF);

class WidgetsReusing {
  static getMaterialBar(
    BuildContext context,
    String message, {
    MessageStatus messageStatus = MessageStatus.info,
  }) {
    ScaffoldMessenger.of(
      context,
    ).removeCurrentMaterialBanner(reason: MaterialBannerClosedReason.hide);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        onVisible: () {
          Future.delayed(const Duration(seconds: 2)).then((value) {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
              reason: MaterialBannerClosedReason.hide,
            );
          });
        },
        actions: [const SizedBox()],
        elevation: 800,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        backgroundColor: Colors.transparent,
        leadingPadding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 20, left: 15, right: 5, top: 10),
        content: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
              reason: MaterialBannerClosedReason.dismiss,
            );
          },
          child: getMessageView(context, message, messageStatus),
        ),
      ),
    );
  }

  static getMessageView(
    BuildContext context,
    String title,
    MessageStatus messageStatus,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
          reason: MaterialBannerClosedReason.dismiss,
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: WidgetsReusing.linearGradient,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 218, 218, 218),
              blurRadius: 7, // soften the shadow
              spreadRadius: 3, //extend the shadow
              offset: Offset(
                1, // Move to right 10  horizontally
                5.0, // Move to bottom 10 Vertically
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.left,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const linearGradient = LinearGradient(
    colors: [primaryColor, primaryColor1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    tileMode: TileMode.mirror,
  );

  static const linearGradient2 = LinearGradient(
    colors: [accentColorRed, accentColorRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    tileMode: TileMode.mirror,
  );

  static const linearGradientDim = LinearGradient(
    colors: [primaryColorDim, primaryColor1Dim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    tileMode: TileMode.mirror,
  );

  static Widget getTextButton(
    context,
    String text,
    onTap,
    edgeinsets, {
    bool isDim = false,
  }) {
    return Container(
      margin: edgeinsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDim ? linearGradientDim : linearGradient,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: InkWell(
            onTap: onTap,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: isDim ? Colors.black : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget invoiceButtonText(
    context,
    String text,
    onTap,
    edgeinsets, {
    bool isDim = false,
  }) {
    return Container(
      margin: edgeinsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDim ? linearGradientDim : linearGradient,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: InkWell(
            onTap: onTap,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: isDim ? Colors.black : Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget getPassCodeButton(
    context,
    String text,
    onTap,
    edgeinsets,
    textStyle,
  ) {
    return Container(
      margin: edgeinsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 45,
          width: double.infinity,
          decoration: const BoxDecoration(
            // gradient: WidgetsSpecific.linearGradient,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: InkWell(
            onTap: onTap,
            child: Align(
              alignment: Alignment.center,
              child: Text(text, style: textStyle),
            ),
          ),
        ),
      ),
    );
  }

  static Widget getPassCodeButtonIcon(context, onTap, edgeinsets, textStyle) {
    return Container(
      margin: edgeinsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 55,
          width: double.infinity,
          decoration: const BoxDecoration(
            // gradient: WidgetsSpecific.linearGradient,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: InkWell(
            onTap: onTap,
            child: Align(
              alignment: Alignment.center,
              child: GradientIconButton(
                child: const Icon(
                  Icons.backspace_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget getTextButtonTransparent(
    context,
    String text,
    onTap,
    edgeinsets,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: edgeinsets,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            // color: Theme.of(context).colorScheme.secondary,
            color: Colors.black87,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        height: 50,
        child: Text(
          text,
          style: TextStyle(
            // color: Theme.of(context).colorScheme.secondary,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  //========= Get Appbar Widgets ============================================

  static Widget getAppBarActionText(
    int listLength,
    String title,
    GestureTapCallback onTap,
  ) {
    return listLength > 0
        ? InkWell(onTap: onTap, child: Text(title, style: TextStyle()))
        : const SizedBox();
  }

  static Widget getAppBarActionText2(String title, GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 5),
        child: Text(title, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static Widget getAppBarActionIcon(
    IconData iconData,
    GestureTapCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 10),
        child: Icon(iconData, color: Colors.white),
      ),
    );
  }

  static Widget getAppbarLeading(
    GestureTapCallback onTap, {
    IconData iconData = Icons.arrow_back,
  }) {
    return InkWell(onTap: onTap, child: Icon(iconData, color: Colors.white));
  }

  static Widget getAppBarTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }
}

class GradientIconButton extends StatelessWidget {
  const GradientIconButton({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => const RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [primaryColor, primaryColor1],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
      child: child,
    );
  }
}
