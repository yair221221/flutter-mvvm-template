package yair.mobileApp.flutter_mvvm_template

import android.Manifest
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Native bridge for Android's step counter sensor (TYPE_STEP_COUNTER).
 *
 * TYPE_STEP_COUNTER is cumulative since device reboot, so we track a daily
 * baseline in SharedPreferences. When the date changes, we update the baseline.
 *
 * Flutter calls:
 *   hasPermission()  → Boolean
 *   getStepsToday()  → Int (steps since midnight; 0 if sensor not available)
 */
class StepCounterChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) : SensorEventListener {

    companion object {
        const val CHANNEL = "yair.mobileApp/step_counter"
        private const val PREFS_NAME = "step_counter_prefs"
        private const val KEY_BASELINE = "step_baseline"
        private const val KEY_BASELINE_DATE = "step_baseline_date"
    }

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private var pendingResult: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(hasPermission())
                "getStepsToday" -> getStepsToday(result)
                else            -> result.notImplemented()
            }
        }
    }

    private fun hasPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(
                context, Manifest.permission.ACTIVITY_RECOGNITION
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true // ACTIVITY_RECOGNITION not required before Android 10
        }
    }

    private fun getStepsToday(result: MethodChannel.Result) {
        if (stepSensor == null) {
            result.success(0)
            return
        }
        if (!hasPermission()) {
            result.success(0) // permission not granted — treated as 0
            return
        }
        // Register a one-shot listener; unregister in onSensorChanged
        pendingResult = result
        sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onSensorChanged(event: SensorEvent) {
        sensorManager.unregisterListener(this)
        val totalSteps = event.values[0].toLong()

        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        val storedDate = prefs.getString(KEY_BASELINE_DATE, null)
        val storedBaseline = prefs.getLong(KEY_BASELINE, -1L)

        val stepsToday: Long = if (storedDate == today && storedBaseline >= 0) {
            (totalSteps - storedBaseline).coerceAtLeast(0)
        } else {
            // New day or first-ever read — set today's baseline
            prefs.edit()
                .putString(KEY_BASELINE_DATE, today)
                .putLong(KEY_BASELINE, totalSteps)
                .apply()
            0L
        }

        pendingResult?.success(stepsToday.toInt())
        pendingResult = null
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
}
