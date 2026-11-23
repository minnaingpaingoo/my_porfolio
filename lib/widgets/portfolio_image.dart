import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

/// Renders either a bundled Flutter asset (`assets/...`) or a remote network image
/// (`http://...` or `https://...`) with graceful fallback UI.
/// Automatically tints dark monochrome icon assets (`web.png`, `ios.png`,
/// `desktop.png`, `github.png`) to bright `whitePrimary` on dark surfaces
/// (or dark charcoal when `forLightSurface: true`).
class PortfolioImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? color;
  final bool forLightSurface;

  const PortfolioImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
    this.color,
    this.forLightSurface = false,
  });

  bool get _isNetwork =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  bool _needsMonochromeTint(String path) {
    if (_isNetwork) return false;
    final lower = path.toLowerCase();
    return lower.endsWith('web.png') ||
        lower.endsWith('ios.png') ||
        lower.endsWith('desktop.png') ||
        lower.endsWith('github.png');
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();
    final effectiveColor = color ??
        (_needsMonochromeTint(trimmed)
            ? (forLightSurface
                ? const Color(0xff0F172A)
                : CustomColor.whitePrimary)
            : null);
    Widget child;

    if (trimmed.isEmpty) {
      child = _buildFallback();
    } else if (_isNetwork) {
      child = Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        color: effectiveColor,
        errorBuilder: (_, __, ___) => _buildFallback(),
        loadingBuilder: (context, widget, loadingProgress) {
          if (loadingProgress == null) return widget;
          return Container(
            width: width,
            height: height,
            color: forLightSurface
                ? const Color(0xffF1F5F9)
                : CustomColor.bgLight1,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CustomColor.yellowPrimary,
              ),
            ),
          );
        },
      );
    } else {
      child = Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        color: effectiveColor,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: forLightSurface ? const Color(0xffF1F5F9) : CustomColor.bgLight1,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: forLightSurface
            ? const Color(0xff2563EB)
            : CustomColor.yellowSecondary,
        size: (width != null && width! < 40) ? width! * 0.7 : 32,
      ),
    );
  }
}
