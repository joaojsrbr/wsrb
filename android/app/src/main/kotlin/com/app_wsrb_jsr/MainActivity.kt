package com.app_wsrb_jsr


import android.content.res.Configuration
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import cl.puntito.simple_pip_mode.PipCallbackHelper
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private var callbackHelper = PipCallbackHelper()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.e("WSRB","configureFlutterEngine")
        super.configureFlutterEngine(flutterEngine)
        callbackHelper.configureFlutterEngine(flutterEngine)
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration?
    ) {
        callbackHelper.onPictureInPictureModeChanged(isInPictureInPictureMode)
    }
}
