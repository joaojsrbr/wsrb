package com.app_wsrb_jsr


import android.content.res.Configuration
import com.ryanheise.audioservice.AudioServiceActivity
import com.thesparks.android_pip.PipCallbackHelper
import io.flutter.embedding.engine.FlutterEngine


class MainActivity : AudioServiceActivity() {
    private var callbackHelper = PipCallbackHelper()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        callbackHelper.configureFlutterEngine(flutterEngine)
    }

    override fun onPictureInPictureModeChanged(active: Boolean, newConfig: Configuration?) {
        callbackHelper.onPictureInPictureModeChanged(active)
    }
}
