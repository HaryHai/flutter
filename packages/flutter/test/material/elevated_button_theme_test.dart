// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Passing no ElevatedButtonTheme returns defaults', (WidgetTester tester) async {
    const ColorScheme colorScheme = ColorScheme.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(colorScheme: colorScheme),
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () { },
              child: const Text('button'),
            ),
          ),
        ),
      ),
    );

    final Finder buttonMaterial = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.byType(Material),
    );

    final Material material = tester.widget<Material>(buttonMaterial);
    expect(material.animationDuration, const Duration(milliseconds: 200));
    expect(material.borderRadius, null);
    expect(material.color, colorScheme.primary);
    expect(material.elevation, 2);
    expect(material.shadowColor, const Color(0xff000000));
    expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));
    expect(material.textStyle!.color, colorScheme.onPrimary);
    expect(material.textStyle!.fontFamily, 'Roboto');
    expect(material.textStyle!.fontSize, 14);
    expect(material.textStyle!.fontWeight, FontWeight.w500);

    final Align align = tester.firstWidget<Align>(find.ancestor(of: find.text('button'), matching: find.byType(Align)));
    expect(align.alignment, Alignment.center);
  });

  group('[Theme, TextTheme, ElevatedButton style overrides]', () {
    const Color primaryColor = Color(0xff000001);
    const Color onSurfaceColor = Color(0xff000002);
    const Color shadowColor = Color(0xff000004);
    const Color onPrimaryColor = Color(0xff000005);
    const double elevation = 1;
    const TextStyle textStyle = TextStyle(fontSize: 12.0);
    const EdgeInsets padding = EdgeInsets.all(3);
    const Size minimumSize = Size(200, 200);
    const BorderSide side = BorderSide(color: Colors.green, width: 2);
    const OutlinedBorder shape = RoundedRectangleBorder(side: side, borderRadius: BorderRadius.all(Radius.circular(2)));
    const MouseCursor enabledMouseCursor = SystemMouseCursors.text;
    const MouseCursor disabledMouseCursor = SystemMouseCursors.grab;
    const MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.shrinkWrap;
    const Duration animationDuration = Duration(milliseconds: 25);
    const bool enableFeedback = false;
    const AlignmentGeometry alignment = Alignment.centerLeft;

    final ButtonStyle style = ElevatedButton.styleFrom(
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      onSurface: onSurfaceColor,
      shadowColor: shadowColor,
      elevation: elevation,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      side: side,
      shape: shape,
      enabledMouseCursor: enabledMouseCursor,
      disabledMouseCursor: disabledMouseCursor,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
    );

    Widget buildFrame({ ButtonStyle? buttonStyle, ButtonStyle? themeStyle, ButtonStyle? overallStyle }) {
      final Widget child = Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            style: buttonStyle,
            onPressed: () { },
            child: const Text('button'),
          );
        },
      );
      return MaterialApp(
        theme: ThemeData.from(colorScheme: const ColorScheme.light()).copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(style: overallStyle),
        ),
        home: Scaffold(
          body: Center(
            // If the ElevatedButtonTheme widget is present, it's used
            // instead of the Theme's ThemeData.ElevatedButtonTheme.
            child: themeStyle == null ? child : ElevatedButtonTheme(
              data: ElevatedButtonThemeData(style: themeStyle),
              child: child,
            ),
          ),
        ),
      );
    }

    final Finder findMaterial = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.byType(Material),
    );

    final Finder findInkWell = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.byType(InkWell),
    );

    const Set<MaterialState> enabled = <MaterialState>{};
    const Set<MaterialState> disabled = <MaterialState>{ MaterialState.disabled };
    const Set<MaterialState> hovered = <MaterialState>{ MaterialState.hovered };
    const Set<MaterialState> focused = <MaterialState>{ MaterialState.focused };
    const Set<MaterialState> pressed = <MaterialState>{ MaterialState.pressed };

    void checkButton(WidgetTester tester) {
      final Material material = tester.widget<Material>(findMaterial);
      final InkWell inkWell = tester.widget<InkWell>(findInkWell);
      expect(material.textStyle!.color, onPrimaryColor);
      expect(material.textStyle!.fontSize, 12);
      expect(material.color, primaryColor);
      expect(material.shadowColor, shadowColor);
      expect(material.elevation, elevation);
      expect(MaterialStateProperty.resolveAs<MouseCursor>(inkWell.mouseCursor!, enabled), enabledMouseCursor);
      expect(MaterialStateProperty.resolveAs<MouseCursor>(inkWell.mouseCursor!, disabled), disabledMouseCursor);
      expect(inkWell.overlayColor!.resolve(hovered), onPrimaryColor.withOpacity(0.08));
      expect(inkWell.overlayColor!.resolve(focused), onPrimaryColor.withOpacity(0.24));
      expect(inkWell.overlayColor!.resolve(pressed), onPrimaryColor.withOpacity(0.24));
      expect(inkWell.enableFeedback, enableFeedback);
      expect(material.borderRadius, null);
      expect(material.shape, shape);
      expect(material.animationDuration, animationDuration);
      expect(tester.getSize(find.byType(ElevatedButton)), const Size(200, 200));
      final Align align = tester.firstWidget<Align>(find.ancestor(of: find.text('button'), matching: find.byType(Align)));
      expect(align.alignment, alignment);
    }

    testWidgets('Button style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(buttonStyle: style));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets('Button theme style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(themeStyle: style));
      await tester.pumpAndSettle();
      checkButton(tester);
    });

    testWidgets('Overall Theme button theme style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(overallStyle: style));
      await tester.pumpAndSettle();
      checkButton(tester);
    });

    // Same as the previous tests with empty ButtonStyle's instead of null.

    testWidgets('Button style overrides defaults, empty theme and overall styles', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(buttonStyle: style, themeStyle: const ButtonStyle(), overallStyle: const ButtonStyle()));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets('Button theme style overrides defaults, empty button and overall styles', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(buttonStyle: const ButtonStyle(), themeStyle: style, overallStyle: const ButtonStyle()));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets('Overall Theme button theme style overrides defaults, null theme and empty overall style', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(buttonStyle: const ButtonStyle(), themeStyle: null, overallStyle: style));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });
  });

  testWidgets('Theme shadowColor', (WidgetTester tester) async {
    const ColorScheme colorScheme = ColorScheme.light();
    const Color shadowColor = Color(0xff000001);
    const Color overriddenColor = Color(0xff000002);

    Widget buildFrame({ Color? overallShadowColor, Color? themeShadowColor, Color? shadowColor }) {
      return MaterialApp(
        theme: ThemeData.from(colorScheme: colorScheme).copyWith(
          shadowColor: overallShadowColor,
        ),
        home: Scaffold(
          body: Center(
            child: ElevatedButtonTheme(
              data: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shadowColor: themeShadowColor,
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: shadowColor,
                    ),
                    onPressed: () { },
                    child: const Text('button'),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    final Finder buttonMaterialFinder = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.byType(Material),
    );

    await tester.pumpWidget(buildFrame());
    Material material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, Colors.black); //default

    await tester.pumpWidget(buildFrame(overallShadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(buildFrame(themeShadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(buildFrame(shadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(buildFrame(overallShadowColor: overriddenColor, themeShadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(buildFrame(themeShadowColor: overriddenColor, shadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);
  });
}
