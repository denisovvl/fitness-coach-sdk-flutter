import 'dart:ui';

/// Optional branding overrides applied to the SDK at initialization.
///
/// Any field left `null` falls back to the SDK's built-in defaults.
class SdkTheme {
  const SdkTheme({this.colors, this.cornersRounding});

  final SdkColors? colors;
  final SdkCornerRounding? cornersRounding;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (colors != null) map['colors'] = colors!.toMap();
    if (cornersRounding != null) {
      map['cornersRounding'] = cornersRounding!.toMap();
    }
    return map;
  }
}

/// Color overrides keyed by the designer token path shared across platforms
/// (e.g. `brand/primary`, `overlay/black-dark`). Each field is optional;
/// unset fields keep the SDK default.
class SdkColors {
  const SdkColors({
    this.brandPrimary,
    this.brandSecondary,
    this.brandTertiary,
    this.textHeadingDarkPrimary,
    this.textHeadingLightPrimary,
    this.textBodyDarkPrimary,
    this.textBodyDarkSecondary,
    this.textBodyLightPrimary,
    this.textBodyLightSecondary,
    this.textBodyBluePrimary,
    this.textBodyBlueSecondary,
    this.textBodyYellowPrimary,
    this.textBodyOrchidPrimary,
    this.overlayBlackDark,
    this.overlayBlackMedium,
    this.overlayCadetMedium,
    this.buttonBgDarkPrimary,
    this.buttonBgDarkSecondary,
    this.buttonBgLightPrimary,
    this.buttonBgLightSecondary,
    this.buttonBgLightYellow,
    this.buttonBgLightOrchid,
    this.buttonBgLightBlue,
    this.buttonBgIconTransparent,
    this.bgWhite,
    this.bgLightGrey,
  });

  final Color? brandPrimary;
  final Color? brandSecondary;
  final Color? brandTertiary;

  final Color? textHeadingDarkPrimary;
  final Color? textHeadingLightPrimary;

  final Color? textBodyDarkPrimary;
  final Color? textBodyDarkSecondary;
  final Color? textBodyLightPrimary;
  final Color? textBodyLightSecondary;
  final Color? textBodyBluePrimary;
  final Color? textBodyBlueSecondary;
  final Color? textBodyYellowPrimary;
  final Color? textBodyOrchidPrimary;

  final Color? overlayBlackDark;
  final Color? overlayBlackMedium;
  final Color? overlayCadetMedium;

  final Color? buttonBgDarkPrimary;
  final Color? buttonBgDarkSecondary;
  final Color? buttonBgLightPrimary;
  final Color? buttonBgLightSecondary;
  final Color? buttonBgLightYellow;
  final Color? buttonBgLightOrchid;
  final Color? buttonBgLightBlue;
  final Color? buttonBgIconTransparent;

  final Color? bgWhite;
  final Color? bgLightGrey;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    void put(String key, Color? color) {
      if (color != null) map[key] = color.toARGB32();
    }

    put('brand/primary', brandPrimary);
    put('brand/secondary', brandSecondary);
    put('brand/tertiary', brandTertiary);

    put('text/heading/dark-primary', textHeadingDarkPrimary);
    put('text/heading/light-primary', textHeadingLightPrimary);

    put('text/body/dark-primary', textBodyDarkPrimary);
    put('text/body/dark-secondary', textBodyDarkSecondary);
    put('text/body/light-primary', textBodyLightPrimary);
    put('text/body/light-secondary', textBodyLightSecondary);
    put('text/body/blue-primary', textBodyBluePrimary);
    put('text/body/blue-secondary', textBodyBlueSecondary);
    put('text/body/yellow-primary', textBodyYellowPrimary);
    put('text/body/orchid-primary', textBodyOrchidPrimary);

    put('overlay/black-dark', overlayBlackDark);
    put('overlay/black-medium', overlayBlackMedium);
    put('overlay/cadet-medium', overlayCadetMedium);

    put('button/bg-dark-primary', buttonBgDarkPrimary);
    put('button/bg-dark-secondary', buttonBgDarkSecondary);
    put('button/bg-light-primary', buttonBgLightPrimary);
    put('button/bg-light-secondary', buttonBgLightSecondary);
    put('button/bg-light-yellow', buttonBgLightYellow);
    put('button/bg-light-orchid', buttonBgLightOrchid);
    put('button/bg-light-blue', buttonBgLightBlue);
    put('button/bg-icon-transparent', buttonBgIconTransparent);

    put('bg/white', bgWhite);
    put('bg/light-grey', bgLightGrey);

    return map;
  }
}

/// Corner-radius overrides keyed by the designer token path shared across
/// platforms (e.g. `button/border`). Each field is optional; unset fields keep
/// the SDK default.
class SdkCornerRounding {
  const SdkCornerRounding({this.buttonBorder});

  final SdkRadius? buttonBorder;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (buttonBorder != null) map['button/border'] = buttonBorder!.toMap();
    return map;
  }
}

/// A resolved corner radius: a fixed point value or a fully-rounded pill.
/// Use `SdkRadius.value(0)` for no rounding.
sealed class SdkRadius {
  const SdkRadius();

  /// A fixed radius in logical points. Pass `0` to disable rounding.
  const factory SdkRadius.value(double value) = SdkRadiusValue;

  /// A pill shape — corners rounded to half the shorter side.
  const factory SdkRadius.pill() = SdkRadiusPill;

  Map<String, dynamic> toMap();
}

class SdkRadiusValue extends SdkRadius {
  const SdkRadiusValue(this.value);

  final double value;

  @override
  Map<String, dynamic> toMap() => {'type': 'value', 'value': value};
}

class SdkRadiusPill extends SdkRadius {
  const SdkRadiusPill();

  @override
  Map<String, dynamic> toMap() => const {'type': 'pill'};
}
