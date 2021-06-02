import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyMaterialTextSelectionControls extends MaterialTextSelectionControls {
  // Padding between the toolbar and the anchor.
  static const double _kToolbarContentDistanceBelow = 20.0;
  static const double _kToolbarContentDistance = 15.0;

  final Function(TextSelectionDelegate) onTapUnderline;
  final Function(Color, TextSelectionDelegate) onTapHighlight;

  MyMaterialTextSelectionControls({
    required this.onTapUnderline,
    required this.onTapHighlight,
  });
  // Builder for handles
  // @override
  // Widget buildHandle(BuildContext context, TextSelectionHandleType type,
  //     double textLineHeight) {
  //   switch (type) {
  //     case TextSelectionHandleType.left:
  //       return Transform.translate(
  //         child: SvgPicture.asset(
  //           'svg/selectionHandles/leftHandle.svg',
  //         ),
  //         offset: Offset(9.5, -57.5),
  //       );
  //     case TextSelectionHandleType.right:
  //       return Transform.translate(
  //         child: SvgPicture.asset(
  //           'svg/selectionHandles/rightHandle.svg',
  //         ),
  //         offset: Offset(-9.5, -25.0),
  //       );
  //     case TextSelectionHandleType.collapsed:
  //       return SizedBox.shrink();
  //   }
  // }

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx + 20.0,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            _kToolbarContentDistance -
            25.0);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return MyTextSelectionToolbar(
      delegate: delegate,
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus,
      handleHighlight: onTapHighlight,
      handleUnderline: onTapUnderline,

      // handleCustomButton: () {
      //   delegate.textEditingValue = delegate.textEditingValue.copyWith(
      //     selection: TextSelection.collapsed(
      //       offset: delegate.textEditingValue.selection.baseOffset,
      //     ),
      //   );
      //   delegate.hideToolbar();
      // },
      // handleCut: canCut(delegate) && handleCut != null
      //     ? () => handleCut(delegate)
      //     : null,
      // handlePaste: canPaste(delegate) && handlePaste != null
      //     ? () => handlePaste(delegate)
      //     : null,
      // handleSelectAll: canSelectAll(delegate) && handleSelectAll != null
      //     ? () => handleSelectAll(delegate)
      //     : null,
    );
  }
}

class MyTextSelectionToolbar extends StatefulWidget {
  const MyTextSelectionToolbar({
    Key? key,
    required this.delegate,
    this.anchorAbove,
    this.anchorBelow,
    this.clipboardStatus,
    required this.handleHighlight,
    required this.handleUnderline,
    this.handleShare,
    this.handleRemoveHighlight,
  }) : super(key: key);

  final TextSelectionDelegate delegate;
  final Offset? anchorAbove;
  final Offset? anchorBelow;
  final ClipboardStatusNotifier? clipboardStatus;
  final Function(TextSelectionDelegate) handleUnderline;
  final Function(Color, TextSelectionDelegate) handleHighlight;
  final VoidCallback? handleShare;
  final VoidCallback? handleRemoveHighlight;

  @override
  MyTextSelectionToolbarState createState() => MyTextSelectionToolbarState();
}

class MyTextSelectionToolbarState extends State<MyTextSelectionToolbar> {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus!.addListener(_onChangedClipboardStatus);
    widget.clipboardStatus!.update();
  }

  @override
  void didUpdateWidget(MyTextSelectionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus!.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus!.removeListener(_onChangedClipboardStatus);
    }
    widget.clipboardStatus!.update();
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.clipboardStatus!.disposed) {
      widget.clipboardStatus!.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    final List<ColorCirlce> highlightColors = [
      ColorCirlce(color: Colors.blue),
      ColorCirlce(color: Colors.red),
      ColorCirlce(color: Colors.green),
      ColorCirlce(color: Colors.orange),
    ];

    return TextSelectionToolbar(
        anchorAbove: widget.anchorAbove!,
        anchorBelow: widget.anchorBelow!,
        toolbarBuilder: (BuildContext context, Widget child) {
          return Material(
            elevation: 2.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              height: 100.0,
              width: 250.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  child,
                  Container(
                    width: 225.0,
                    height: 2.0,
                    color: Color(0xFFECECEC),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Remove Highlight',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            color: Colors.white,
          );
        },
        children: [
          Container(
            child: Row(
              children: [
                ...List.generate(highlightColors.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: InkWell(
                      onTap: () => widget.handleHighlight(
                          highlightColors[index].color, widget.delegate),
                      child: highlightColors[index],
                    ),
                  );
                }).toList(),
                IconButton(
                  // padding: EdgeInsets.only(left: 15.0),
                  alignment: Alignment.centerRight,
                  icon: Icon(Icons.format_underline),
                  onPressed: () {},
                ),
                IconButton(
                  alignment: Alignment.centerLeft,
                  icon: Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ]);
  }
}

class ColorCirlce extends StatelessWidget {
  final Color color;
  ColorCirlce({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0,
      width: 25.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
