package com.zerotwoonetrade.assignment.app.zero_two_one_trade_assignment

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Collections
import java.util.Random
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit
import kotlin.math.max

class LightTradeStreamer(messenger: BinaryMessenger, private val random: Random = Random()) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private data class InstrumentState(
        val marketKey: String, val fundId: String, val exchange: String,
        val assetType: String, val symbol: String, var currentLtpMinor: Long,
        var previousLtpMinor: Long, val previousCloseMinor: Long, val tickSizeMinor: Long,
        var lastUpdatedAt: Long = 0L, var sequence: Long = 0L,
    )

    private val mainHandler = Handler(Looper.getMainLooper())
    private val worker: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor { runnable ->
        Thread(runnable, "LightTradeStreamer").apply { isDaemon = true }
    }
    private val controlChannel = MethodChannel(messenger, CONTROL_CHANNEL)
    private val eventChannel = EventChannel(messenger, PRICE_CHANNEL)
    private val sessionStates = mutableMapOf<String, InstrumentState>()
    private val activeIds = linkedSetOf<String>()
    private var eventSink: EventChannel.EventSink? = null
    private var ticker: ScheduledFuture<*>? = null
    private var batchSequence = 0L
    private var paused = false
    @Volatile private var disposed = false

    init {
        controlChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "subscribe" -> subscribe(call, result)
            "unsubscribe" -> unsubscribe(call, result)
            "pause" -> worker.execute { paused = true; stopTicker(); replySuccess(result) }
            "resume" -> worker.execute { paused = false; ensureTicker(); replySuccess(result) }
            else -> result.notImplemented()
        }
    }

    private fun subscribe(call: MethodCall, result: MethodChannel.Result) {
        val raw = call.argument<List<Map<String, Any?>>>("instruments")
        if (raw == null) { result.error("invalid_subscription", "Missing instruments.", null); return }
        val seeds = mutableListOf<InstrumentState>()
        for (seed in raw) {
            val id = (seed["marketKey"] ?: seed["instrumentId"]) as? String
            val fundId = seed["fundId"] as? String ?: id
            val exchange = seed["exchange"] as? String ?: "NSE"
            val assetType = seed["assetType"] as? String ?: "equity"
            val symbol = seed["symbol"] as? String
            val ltp = (seed["ltpMinor"] as? Number)?.toLong()
            val close = (seed["previousCloseMinor"] as? Number)?.toLong()
            val tick = (seed["tickSizeMinor"] as? Number)?.toLong()
            if (id.isNullOrBlank() || symbol == null || ltp == null || ltp <= 0 ||
                close == null || close <= 0 || tick == null || tick <= 0) {
                result.error("invalid_subscription", "Invalid instrument seed.", id); return
            }
            seeds += InstrumentState(id, fundId.orEmpty(), exchange, assetType, symbol, ltp, ltp, close, tick)
        }
        worker.execute {
            for (seed in seeds) {
                sessionStates.putIfAbsent(seed.marketKey, seed)
                activeIds += seed.marketKey
            }
            ensureTicker(); replySuccess(result)
        }
    }

    private fun unsubscribe(call: MethodCall, result: MethodChannel.Result) {
        val ids = call.argument<List<String>>("instrumentIds")
        if (ids == null) { result.error("invalid_unsubscribe", "Missing instrumentIds.", null); return }
        worker.execute {
            activeIds.removeAll(ids.toSet())
            if (activeIds.isEmpty()) stopTicker()
            replySuccess(result)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) { worker.execute { eventSink = events } }
    override fun onCancel(arguments: Any?) { worker.execute { eventSink = null } }

    private fun ensureTicker() {
        if (disposed || paused || activeIds.isEmpty() || ticker?.isDone == false) return
        ticker = worker.scheduleAtFixedRate(::generateTick, 1, 1, TimeUnit.SECONDS)
    }

    private fun stopTicker() { ticker?.cancel(false); ticker = null }

    private fun generateTick() {
        if (disposed || paused || activeIds.isEmpty()) return
        val ids = activeIds.toMutableList(); Collections.shuffle(ids, random)
        val updateCount = 1 + random.nextInt(ids.size)
        val timestamp = System.currentTimeMillis(); val sequence = ++batchSequence
        val updates = ArrayList<Map<String, Any>>(updateCount)
        for (id in ids.take(updateCount)) {
            val state = sessionStates[id] ?: continue
            val previous = state.currentLtpMinor
            val roll = random.nextInt(100)
            val maxTicks = if (state.assetType == "index" || state.assetType == "marketIndex") 4 else 8
            val requestedDelta = state.tickSizeMinor * (1 + random.nextInt(maxTicks))
            val delta = minOf(requestedDelta, max(state.tickSizeMinor, previous / 200L))
            val next = when { roll < 15 -> previous; roll < 58 -> previous + delta; else -> max(state.tickSizeMinor, previous - delta) }
            state.previousLtpMinor = previous; state.currentLtpMinor = next
            state.lastUpdatedAt = timestamp; state.sequence = sequence
            val change = next - state.previousCloseMinor
            val direction = when { next > previous -> "up"; next < previous -> "down"; else -> "flat" }
            updates += mapOf(
                "marketKey" to state.marketKey, "instrumentId" to state.marketKey,
                "fundId" to state.fundId, "exchange" to state.exchange,
                "assetType" to state.assetType, "symbol" to state.symbol,
                "ltpMinor" to next, "previousLtpMinor" to previous,
                "previousCloseMinor" to state.previousCloseMinor, "changeMinor" to change,
                "changePercent" to change.toDouble() / state.previousCloseMinor * 100.0,
                "direction" to direction,
            )
        }
        if (updates.isEmpty()) return
        val sink = eventSink ?: return
        val batch = mapOf("sequence" to sequence, "timestamp" to timestamp, "updates" to updates)
        mainHandler.post { if (!disposed) sink.success(batch) }
    }

    private fun replySuccess(result: MethodChannel.Result) { mainHandler.post { if (!disposed) result.success(null) } }

    fun dispose() {
        if (disposed) return
        disposed = true; controlChannel.setMethodCallHandler(null); eventChannel.setStreamHandler(null)
        stopTicker(); eventSink = null; activeIds.clear(); sessionStates.clear(); worker.shutdownNow()
    }

    companion object {
        private const val CONTROL_CHANNEL = "light_trade_streamer/control"
        private const val PRICE_CHANNEL = "light_trade_streamer/prices"
    }
}
