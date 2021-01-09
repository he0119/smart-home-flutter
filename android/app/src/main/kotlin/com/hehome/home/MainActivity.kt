package com.hehome.home

import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import androidx.annotation.NonNull
import com.xiaomi.mipush.sdk.MiPushClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "hehome.xyz/push"

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)

    Log.i("New Intent", intent.data.toString())
    Log.i("New Intent", intent.extras?.getString("route"))
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
