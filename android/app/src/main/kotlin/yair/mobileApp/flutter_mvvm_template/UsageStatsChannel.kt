package yair.mobileApp.flutter_mvvm_template

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native bridge to Android's UsageStatsManager.
 *
 * Flutter calls:
 *   hasUsagePermission()  → Boolean
 *   openUsageSettings()   → void
 *   getUsageStats(startMs: Long, endMs: Long) → List<Map<String, Any>>
 *     Each map: { packageName, totalTimeMs }
 */
class UsageStatsChannel(private val context: Context, messenger: BinaryMessenger) {

    companion object {
        const val CHANNEL = "yair.mobileApp/usage_stats"
    }

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            onMethodCall(call, result)
        }
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasUsagePermission" -> result.success(hasPermission())

            "openUsageSettings" -> {
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                result.success(null)
            }

            "getUsageStats" -> {
                val startMs = call.argument<Long>("startMs")
                val endMs   = call.argument<Long>("endMs")
                if (startMs == null || endMs == null) {
                    result.error("INVALID_ARGS", "startMs and endMs required", null)
                    return
                }
                try {
                    result.success(queryStats(startMs, endMs))
                } catch (e: Exception) {
                    result.error("QUERY_FAILED", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    // ── Private helpers ────────────────────────────────────────────────────

    private fun hasPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun queryStats(startMs: Long, endMs: Long): List<Map<String, Any>> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startMs, endMs)
            ?: return emptyList()

        // Aggregate by package (multiple entries can exist for the same package)
        val aggregated = mutableMapOf<String, Long>()
        for (s in stats) {
            if (s.totalTimeInForeground > 0) {
                aggregated[s.packageName] =
                    (aggregated[s.packageName] ?: 0L) + s.totalTimeInForeground
            }
        }

        return aggregated.map { (pkg, ms) ->
            mapOf<String, Any>("packageName" to pkg, "totalTimeMs" to ms)
        }
    }
}
