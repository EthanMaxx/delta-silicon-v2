package com.mrj.delta_silicon

import android.content.Context
import android.graphics.Bitmap
import ai.onnxruntime.*
import java.nio.FloatBuffer
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

object OrtHelper {
    private var session: OrtSession? = null

    fun init(context: Context) {
        if (session != null) return
        val modelBytes = context.assets.open("flutter_assets/assets/models/trocr-small-int8.onnx").readBytes()
        val env = OrtEnvironment.getEnvironment()
        session = env.createSession(modelBytes)
    }

    fun recognize(bitmap: Bitmap): String {
        init(MyApplication.context)
        val resized = Bitmap.createScaledBitmap(bitmap, 384, 384, true)
        val floatBuf = FloatBuffer.allocate(1 * 384 * 384 * 3)
        for (y in 0 until 384) {
            for (x in 0 until 384) {
                val px = resized.getPixel(x, y)
                floatBuf.put((px shr 16 and 0xFF) / 255.0f) // R
                floatBuf.put((px shr 8 and 0xFF) / 255.0f)  // G
                floatBuf.put((px and 0xFF) / 255.0f)       // B
            }
        }
        val input = OnnxTensor.createTensor(OrtEnvironment.getEnvironment(), floatBuf, longArrayOf(1, 384, 384, 3))
        val outputs = session?.run(mapOf("input" to input))
        val text = outputs?.get("output")?.value.toString()
        return text?.replace(Regex("[^0-9.]"), "") ?: ""
    }
}

class MyApplication : android.app.Application() {
    companion object {
        lateinit var context: Context
    }
    override fun onCreate() {
        super.onCreate()
        context = applicationContext
    }
}

class MainActivity : FlutterActivity() {
    private val CHANNEL = "delta_silicon/ort"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    OrtHelper.init(this)
                    result.success(null)
                }
                "recognize" -> {
                    val bmp = Bitmap.createBitmap(384, 384, Bitmap.Config.ARGB_8888) // stub bitmap
                    val text = OrtHelper.recognize(bmp)
                    result.success(text)
                }
                else -> result.notImplemented()
            }
        }
    }
}
