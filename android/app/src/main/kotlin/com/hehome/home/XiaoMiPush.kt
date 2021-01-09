package com.hehome.home

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.xiaomi.mipush.sdk.MiPushCommandMessage
import com.xiaomi.mipush.sdk.MiPushMessage
import com.xiaomi.mipush.sdk.PushMessageReceiver

class XiaoMiMessageReceiver : PushMessageReceiver() {
  override fun onNotificationMessageClicked(context: Context?, message: MiPushMessage?) {
    super.onNotificationMessageClicked(context, message)
    if (context != null) {
      val intent: Intent = Intent(Intent.ACTION_VIEW).apply {
        this.data = Uri.parse("https://${BuildConfig.HOST_NAME}/")
        this.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        // 设置初始路由
        putExtra("route", message?.content);
      }
      context.startActivity(intent)
    }
    Log.i("MiPush", "onNotificationMessageClicked: $message")
  }

  override fun onRequirePermissions(context: Context?, p1: Array<out String>?) {
    super.onRequirePermissions(context, p1)
    Log.i("MiPush", "onRequirePermissions: $p1")
  }

  override fun onReceivePassThroughMessage(context: Context?, message: MiPushMessage?) {
    super.onReceivePassThroughMessage(context, message)
    Log.i("MiPush", "onReceivePassThroughMessage: $message")
  }

  override fun onCommandResult(context: Context?, message: MiPushCommandMessage?) {
    super.onCommandResult(context, message)
    Log.i("MiPush", "onCommandResult: $message")
  }

  override fun onReceiveRegisterResult(context: Context?, message: MiPushCommandMessage?) {
    super.onReceiveRegisterResult(context, message)
    Log.i("MiPush", "onReceiveRegisterResult: $message")
    Handler(Looper.getMainLooper()).post {
      MainActivity.channel.invokeMethod("ReceiveRegisterResult", message?.commandArguments?.first())
    }
  }

  override fun onNotificationMessageArrived(context: Context?, message: MiPushMessage?) {
    super.onNotificationMessageArrived(context, message)
    Log.i("MiPush", "onNotificationMessageArrived: $message")
  }
}
