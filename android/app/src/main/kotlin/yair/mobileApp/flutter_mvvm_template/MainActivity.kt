package yair.mobileApp.flutter_mvvm_template

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        UsageStatsChannel(applicationContext, messenger)
        StepCounterChannel(applicationContext, messenger)
    }
}
