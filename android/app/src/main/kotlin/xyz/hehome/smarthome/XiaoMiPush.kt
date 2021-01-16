package xyz.hehome.smarthome

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
    context?.let {
      val intent: Intent = Intent(Intent.ACTION_VIEW).apply {
        this.data = Uri.parse("https://${BuildConfig.HOST_NAME}${message?.content}")
        this.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      }
      context.startActivity(intent)
    }
    Log.i("MiPush", "onNotificationMessageClicked: $message")
  }

  override fun onReceiveRegisterResult(context: Context?, message: MiPushCommandMessage?) {
    super.onReceiveRegisterResult(context, message)
    Log.i("MiPush", "onReceiveRegisterResult: $message")
    Handler(Looper.getMainLooper()).post {
      MainActivity.pushChannel.invokeMethod("ReceiveRegisterResult", message?.commandArguments?.first())
    }
  }

  override fun onNotificationMessageArrived(context: Context?, message: MiPushMessage?) {
    super.onNotificationMessageArrived(context, message)
    Log.i("MiPush", "onNotificationMessageArrived: $message")
  }
}
