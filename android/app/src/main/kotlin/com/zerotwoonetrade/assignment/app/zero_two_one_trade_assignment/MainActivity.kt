package com.zerotwoonetrade.assignment.app.zero_two_one_trade_assignment

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var lightTradeStreamer: LightTradeStreamer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        lightTradeStreamer = LightTradeStreamer(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        lightTradeStreamer?.dispose()
        lightTradeStreamer = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
