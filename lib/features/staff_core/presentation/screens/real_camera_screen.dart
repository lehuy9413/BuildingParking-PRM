/// Stub for non-web platforms.
/// RealCameraScreen is a web-only feature for staff portal.
/// On mobile, we redirect to image picker instead.
library;

export 'real_camera_screen_stub.dart'
    if (dart.library.html) 'real_camera_screen_web.dart';
