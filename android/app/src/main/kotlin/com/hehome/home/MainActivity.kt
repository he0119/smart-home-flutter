package com.hehome.home

import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.xiaomi.mipush.sdk.MiPushClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  lateinit var eventSink: EventChannel.EventSink

  companion object {
    lateinit var channel: MethodChannel
  }

  override fun getInitialRoute(): String? {
    if (intent.action == Intent.ACTION_VIEW) {
      val path = Uri.parse(intent.data.toString()).path
      return path
    }
    return super.getInitialRoute()
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    if (intent.action == Intent.ACTION_VIEW) {
      val path = Uri.parse(intent.data.toString()).path
      eventSink.success(path)
      Log.i("New Intent", path)
    }
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, "hehome.xyz/route").setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(p0: Any?, event: EventChannel.EventSink?) {
          eventSink = event!!
        }

        override fun onCancel(p0: Any?) {}
      }
    )
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hehome.xyz/push/method")
    channel.setMethodCallHandler { call, result ->
      if (call.method == "init") {
        Log.i("Push", "Mipush initializing")
        // 获得参数
        val appId = call.argument<String>("appId")
        val appKey = call.argument<String>("appKey")

        MiPushClient.registerPush(this, appId, appKey)
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }
}
