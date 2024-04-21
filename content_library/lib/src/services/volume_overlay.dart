// import 'package:content_library/content_library.dart';
// import 'package:flutter/services.dart';

// class VolumeOverlay {
//   static const _method = MethodChannel('wsrb_channel_main');

//   VolumeOverlay._();

//   static Future<void> volumeOverlay({
//     bool volumeDown = false,
//     bool volumeUp = false,
//     bool adjustVolume = true,
//   }) async {
//     try {
//       final arguments = {
//         'volume_up': !volumeUp,
//         'volume_down': !volumeDown,
//         'adjust_volume': adjustVolume,
//       };
//       final result = await _method.invokeMethod(
//         'disableVolumeButtons',
//         arguments,
//       );
//       if (result == true) {
//         customLog(
//             'VOLUME_DOWN[$volumeDown] - VOLUME_UP[$volumeDown] - ADJUST_VOLUME[${arguments['adjust_volume']}]');
//       }
//     } on PlatformException catch (_, __) {
//       customLog(_, stackTrace: __);
//     }
//   }
// }
