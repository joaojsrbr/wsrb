package com.app_wsrb_jsr;

import android.content.Context;
import android.media.AudioManager;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    final private String CHANNEL = "wsrb_channel_main";

//    @Override
//    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
//                (call, result) -> {
//                    if (call.method.equals("disableVolumeButtons")) {
//
//                        if(call.hasArgument("volume_up")){
//                            final boolean VOLUME_UP = call.argument("volume_up");
//                            if(this.VOLUME_UP  != VOLUME_UP){
//                                this.VOLUME_UP = VOLUME_UP;
//                            }
//                        }
//
//                        if(call.hasArgument("volume_down")){
//                            final boolean VOLUME_DOWN = call.argument("volume_down");
//                            if(this.VOLUME_DOWN  != VOLUME_DOWN){
//                                this.VOLUME_DOWN = VOLUME_DOWN;
//                            }
//                        }
//
//
//                        if(call.hasArgument("adjust_volume")){
//                            final boolean ADJUST_VOLUME = call.argument("adjust_volume");
//                            if(this.ADJUST_VOLUME  != ADJUST_VOLUME){
//                                this.ADJUST_VOLUME = ADJUST_VOLUME;
//                            }
//                        }
//
//                        result.success(true);
//
//                    } else {
//                        result.notImplemented();
//                    }
//                });
//    }



}