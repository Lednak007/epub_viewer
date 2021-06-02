import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'selected_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectedHighlightText extends StatelessWidget {
  final String text;
  final List<SelectedPattern>?
      patternList; // hamro pattern list yesma rakhni .....

  final TextStyle? defaultStyle;

  final TextSelectionControls? textSelectionControls;

  final TextAlign? textAlign;

  final TextDirection? textDirection;
  final bool softWrap;

  final TextOverflow overflow;

  final double textScaleFactor;

  final int? maxLines;

  final Locale? locale;

  final StrutStyle? strutStyle;

  final TextWidthBasis textWidthBasis;

  final bool caseSensitive;

  final bool selectable;

  SelectedHighlightText(
    this.text, {
    Key? key,
    this.textSelectionControls,
    this.patternList,
    this.defaultStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.caseSensitive = true,
    this.selectable = false,
  });

  _launchURL(String str) async {
    String url = str;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  List<String> specialCharacters() {
    return '\\~[]{}#%^*+=_|<>/£€•.,!’()?-\$'.split('');
  }

  TapGestureRecognizer? tapGestureRecognizerForUrls(
      String str, String urlType) {
    TapGestureRecognizer? tapGestureRecognizer;
    switch (urlType) {
      case 'web':
        if (str.substring(0, 4) != "http") {
          str = "https://$str";
        }
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL(str);
          };
        break;
      case 'email':
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL("mailto:$str");
          };
        break;
      case 'tel':
        tapGestureRecognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchURL("tel:$str");
          };
        break;
      default:
    }
    return tapGestureRecognizer;
  }

  List<String> processStrList(
      List<SelectedPattern> patternList, String temText) {
    List<String> strList = [];
    List<List<int>> positions = [];

    patternList.asMap().forEach((index, pattern) {
      String thisRegExPattern;
      String targetString = pattern.targetString;
      String stringBeforeTarget = pattern.stringBeforeTarget;
      String stringAfterTarget = pattern.stringAfterTarget;

      bool matchLeftWordBoundary = pattern.matchLeftWordBoundary;
      bool matchRightWordBoundary = pattern.matchRightWordBoundary;
      bool matchWordBoundaries = pattern.matchWordBoundaries;
      //if hasSpecialCharacters then unicode is
      bool unicode = !pattern.hasSpecialCharacters;

      String wordBoundaryStringBeforeTarget1 = "\\b";
      String wordBoundaryStringBeforeTarget2 = "\\s";
      String wordBoundaryStringAfterTarget1 = "\\s";
      String wordBoundaryStringAfterTarget2 = "\\b";

      String leftBoundary = "(?<!\\w)";
      String rightBoundary = "(?!\\w)";

      ///if any of matchWordBoundaries or matchLeftWordBoundary is false
      ///set leftBoundary = ""
      if (!matchWordBoundaries || !matchLeftWordBoundary) {
        leftBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringAfterTarget1 = "";
      }

      if (!matchWordBoundaries || !matchRightWordBoundary) {
        rightBoundary = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      bool isHan = RegExp(r"[\u4e00-\u9fa5]+",
              caseSensitive: caseSensitive, unicode: unicode)
          .hasMatch(targetString);

      bool isArabic = RegExp(r"[\u0621-\u064A]+",
              caseSensitive: caseSensitive, unicode: unicode)
          .hasMatch(targetString);

      /// if target string is Han or Arabic character
      /// set matchWordBoundaries = false
      /// set wordBoundaryStringBeforeTarget = ""
      if (isHan || isArabic) {
        matchWordBoundaries = false;
        leftBoundary = "";
        rightBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget1 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      String stringBeforeTargetRegex = "";
      if (stringBeforeTarget != "") {
        stringBeforeTargetRegex =
            "(?<=$wordBoundaryStringBeforeTarget1$stringBeforeTarget$wordBoundaryStringBeforeTarget2)";
      }

      String stringAfterTargetRegex = "";
      if (stringAfterTarget != "") {
        stringAfterTargetRegex =
            "(?=$wordBoundaryStringAfterTarget1$stringAfterTarget$wordBoundaryStringAfterTarget2)";
      }

      //modify targetString by matchWordBoundaries and wordBoundaryStringBeforeTarget settings
      thisRegExPattern =
          '($stringBeforeTargetRegex$leftBoundary$targetString$rightBoundary$stringAfterTargetRegex)';
      RegExp exp = new RegExp(thisRegExPattern,
          caseSensitive: caseSensitive, unicode: unicode);
      var allMatches = exp.allMatches(temText);
      // print(thisRegExPattern);

      //check matchOption ['all','first','last', 0, 1, 2, 3, 10]

      int matchesLength = allMatches.length;
      List<int> matchIndexList = [];
      var matchOption = pattern.matchOption;
      if (matchOption is String) {
        switch (matchOption) {
          case 'all':
            matchIndexList = new List<int>.generate(matchesLength, (i) => i);
            break;
          case 'first':
            matchIndexList = [0];
            break;
          case 'last':
            matchIndexList = [matchesLength - 1];
            break;
          default:
            matchIndexList = new List<int>.generate(matchesLength, (i) => i);
        }
      } else if (matchOption is List<dynamic>) {
        matchOption.forEach(
          (option) {
            switch (option) {
              case 'all':
                matchIndexList =
                    new List<int>.generate(matchesLength, (i) => i);
                break;
              case 'first':
                matchIndexList.add(0);
                break;
              case 'last':
                matchIndexList.add(matchesLength - 1);
                break;
              default:
                if (option is int) matchIndexList.add(option);
            }
          },
        );
      }

      ///eg. positions = [[7,11],[26,30],]
      allMatches.toList().asMap().forEach((index, match) {
        if (matchIndexList.indexOf(index) > -1) {
          positions.add([match.start, match.end]);
        }
      });
    });
    positions.sort((a, b) => a[0].compareTo(b[0]));
    //remove invalid positions
    List<List<int>> postionsToRemove = [];
    for (var i = 1; i < positions.length; i++) {
      if (positions[i][0] <= positions[i - 1][1]) {
        postionsToRemove.add(positions[i]);
      }
    }
    postionsToRemove.forEach((position) {
      positions.remove(position);
    });

    //convert positions to 1d list
    List<int> splitPositions = [0];
    positions.forEach((position) {
      splitPositions.add(position[0]);
      splitPositions.add(position[1]);
    });
    splitPositions.add(temText.length);

    splitPositions.asMap().forEach((index, splitPosition) {
      if (index != 0) {
        strList
            .add(temText.substring(splitPositions[index - 1], splitPosition));
      }
    });

    // print(strList);
    return strList;
  }

  String replaceSpecialCharacters(str) {
    String tempStr = str;
    //\[]()^*+?.$-{}|!
    specialCharacters().forEach((chr) {
      tempStr = tempStr.replaceAll(chr, '\\$chr');
    });

    return tempStr;
  }

  @override
  Widget build(BuildContext context) {
    String temText = text;
    List<SelectedPattern> tempPatternList = patternList!;
    List<SelectedPattern> finalTempPatternList = [];
    List<SelectedPattern> finalTempPatternList2 = [];
    List<String> strList = [];
    bool unicode = true;

    if (tempPatternList == null) {
      strList = [temText];
    } else {
      tempPatternList.asMap().forEach((index, pattern) {
        ///if targetString is a list
        if (pattern.targetString is List<String>) {
          pattern.targetString.asMap().forEach((index, eachTargetString) {
            finalTempPatternList
                .add(pattern.copyWith(targetString: eachTargetString));
          });
        } else {
          finalTempPatternList.add(pattern);
        }
      });

      finalTempPatternList.asMap().forEach((index, pattern) {
        if (pattern.hasSpecialCharacters) {
          unicode = false;
          String newTargetString =
              replaceSpecialCharacters(pattern.targetString);
          finalTempPatternList2
              .add(pattern.copyWith(targetString: newTargetString));
        } else {
          finalTempPatternList2.add(pattern);
        }
      });

      strList = processStrList(finalTempPatternList2, temText);
    }

    List<InlineSpan> textSpanList = [];
    strList.forEach((str) {
      var inlineSpan;
      int targetIndex = -1;
      RegExpMatch? match;

      if (tempPatternList != null) {
        finalTempPatternList2.asMap().forEach((index, pattern) {
          String targetString = pattern.targetString;

          //\$, match end
          RegExp targetStringExp = RegExp(
            '^$targetString\$',
            caseSensitive: caseSensitive,
            unicode: unicode,
          );

          match = targetStringExp.firstMatch(str);

          if (match is RegExpMatch) {
            targetIndex = index;
          }
        });
      }

      ///If str is targetString
      if (targetIndex > -1) {
        //if str is url
        var pattern = finalTempPatternList2[targetIndex];
        var urlType = pattern.urlType;

        if (null != pattern.matchBuilder && match is RegExpMatch) {
          inlineSpan = pattern.matchBuilder!(context, match!);
        } else if (urlType != null) {
          inlineSpan = TextSpan(
            text: str,
            recognizer: tapGestureRecognizerForUrls(str, urlType),
            style: pattern.style == null
                ? DefaultTextStyle.of(context).style
                : pattern.style,
          );
        } else if (pattern.superScript && !selectable) {
          //change the target string to superscript
          inlineSpan = WidgetSpan(
            child: Transform.translate(
              offset: const Offset(0, -5),
              child: Text(
                str,
                textScaleFactor: 0.7,
                style: pattern.style == null
                    ? DefaultTextStyle.of(context).style
                    : pattern.style,
              ),
            ),
          );
        } else if (pattern.subScript && !selectable) {
          //change the target string to subscript
          inlineSpan = WidgetSpan(
            child: Transform.translate(
              offset: const Offset(0, 1),
              child: Text(
                str,
                textScaleFactor: 0.7,
                style: pattern.style == null
                    ? DefaultTextStyle.of(context).style
                    : pattern.style,
              ),
            ),
          );
        } else {
          inlineSpan = TextSpan(
            text: str,
            recognizer: pattern.recognizer,
            style: pattern.style == null
                ? DefaultTextStyle.of(context).style
                : pattern.style,
          );
        }
      } else {
        inlineSpan = TextSpan(
          text: str,
        );
      }
      textSpanList.add(inlineSpan);
    });

    if (selectable) {
      return SelectableText.rich(
        TextSpan(
            style: defaultStyle == null
                ? DefaultTextStyle.of(context).style
                : defaultStyle,
            children: textSpanList),
        style: TextStyle(
          fontSize: 19.5,
          fontFamily: 'Cardo',
          color: Color(0xFF2B2B2B),
        ),
        maxLines: maxLines,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        onSelectionChanged: (s, g) {
          print(s.start);
        },
        selectionControls: textSelectionControls,
        textScaleFactor: textScaleFactor,
        textWidthBasis: textWidthBasis,
      );
    } else {
      return RichText(
        text: TextSpan(
            style: defaultStyle == null
                ? DefaultTextStyle.of(context).style
                : defaultStyle,
            children: textSpanList),
        locale: locale,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        strutStyle: strutStyle,
        textAlign: textAlign!,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        textWidthBasis: textWidthBasis,
      );
    }
  }
}
