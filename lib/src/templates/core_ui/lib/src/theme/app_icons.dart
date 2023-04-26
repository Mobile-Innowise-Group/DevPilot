part of core_ui;

class AppIconSvg {
  static Widget asset(
    String path, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) =>
      SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
      );
}
