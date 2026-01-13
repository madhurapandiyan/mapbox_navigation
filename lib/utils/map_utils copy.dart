import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg_flutter.dart';

class MapBoxUtils {
  static Future<Uint8List> getImageDescriptorFromSvgAsset(
    String assetName,
    Color? color, [
    Size size = const Size(10, 10),
  ]) async {
    final pictureInfo = await vg.loadPicture(
      SvgStringLoader(assetName, colorMapper: MyColorMapper(color: color)),
      null,
    );

    double devicePixelRatio = ui.window.devicePixelRatio;
    int width = (size.width * devicePixelRatio).toInt();
    int height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = math.min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return Uint8List.view(bytes.buffer);
  }

  static Future<Uint8List> getResizedImageBytes(
    String assetName, {
    int targetWidth = 100,
    int targetHeight = 100,
  }) async {
    final data = await rootBundle.load(assetName);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}

class MyColorMapper extends ColorMapper {
  final Color? color;
  const MyColorMapper({this.color});

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color value,
  ) {
    return color ?? value;
  }
}
