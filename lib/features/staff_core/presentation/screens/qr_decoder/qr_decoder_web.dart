import 'dart:html' as html;
import 'dart:js_util' as js_util;

Future<String?> decodeQrFromImageWeb(String path) async {
  try {
    final hasBarcodeDetector = js_util.hasProperty(html.window, 'BarcodeDetector');
    if (!hasBarcodeDetector) {
      throw 'BarcodeDetector is not supported in this browser.';
    }
    
    final detector = js_util.callConstructor(
      js_util.getProperty(html.window, 'BarcodeDetector'), 
      [js_util.jsify({'formats': ['qr_code']})]
    );

    final img = html.ImageElement(src: path);
    await img.onLoad.first;
    
    final barcodes = await js_util.promiseToFuture(
      js_util.callMethod(detector, 'detect', [img])
    );
    
    if (barcodes != null && barcodes.length > 0) {
      final barcode = barcodes[0];
      return js_util.getProperty(barcode, 'rawValue') as String;
    }
  } catch (e) {
    print('Web QR Decode Error: $e');
    throw 'Web QR Decode Error: $e';
  }
  return null;
}
