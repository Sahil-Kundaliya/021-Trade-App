import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius xsBorderRadius = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius smBorderRadius = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius mdBorderRadius = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius lgBorderRadius = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius xlBorderRadius = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius pillBorderRadius = BorderRadius.all(
    Radius.circular(pill),
  );
}
