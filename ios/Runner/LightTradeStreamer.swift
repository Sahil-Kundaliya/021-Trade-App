import Flutter
import Foundation

final class LightTradeStreamer: NSObject, FlutterStreamHandler {
  private struct InstrumentState {
    let marketKey: String; let fundId: String; let exchange: String
    let assetType: String; let symbol: String
    var currentLtpMinor: Int64; var previousLtpMinor: Int64
    let previousCloseMinor: Int64; let tickSizeMinor: Int64
    var lastUpdatedAt: Int64 = 0; var sequence: Int64 = 0
  }

  private let queue = DispatchQueue(label: "com.zerotwoonetrade.lightTradeStreamer", qos: .userInitiated)
  private let controlChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private var sessionStates: [String: InstrumentState] = [:]
  private var activeIds = Set<String>()
  private var eventSink: FlutterEventSink?
  private var timer: DispatchSourceTimer?
  private var batchSequence: Int64 = 0
  private var paused = false
  private var disposed = false

  init(messenger: FlutterBinaryMessenger) {
    controlChannel = FlutterMethodChannel(name: "light_trade_streamer/control", binaryMessenger: messenger)
    eventChannel = FlutterEventChannel(name: "light_trade_streamer/prices", binaryMessenger: messenger)
    super.init()
    controlChannel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    eventChannel.setStreamHandler(self)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "subscribe": subscribe(call.arguments, result: result)
    case "unsubscribe": unsubscribe(call.arguments, result: result)
    case "pause": queue.async { [weak self] in self?.paused = true; self?.stopTicker(); DispatchQueue.main.async { result(nil) } }
    case "resume": queue.async { [weak self] in self?.paused = false; self?.ensureTicker(); DispatchQueue.main.async { result(nil) } }
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func subscribe(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any], let rawSeeds = args["instruments"] as? [[String: Any]] else {
      result(FlutterError(code: "invalid_subscription", message: "Missing instruments.", details: nil)); return
    }
    var seeds: [InstrumentState] = []
    for raw in rawSeeds {
      guard let id = (raw["marketKey"] ?? raw["instrumentId"]) as? String, !id.isEmpty,
        let symbol = raw["symbol"] as? String,
        let ltp = (raw["ltpMinor"] as? NSNumber)?.int64Value, ltp > 0,
        let close = (raw["previousCloseMinor"] as? NSNumber)?.int64Value, close > 0,
        let tick = (raw["tickSizeMinor"] as? NSNumber)?.int64Value, tick > 0 else {
        result(FlutterError(code: "invalid_subscription", message: "Invalid instrument seed.", details: nil)); return
      }
      let fundId = raw["fundId"] as? String ?? id
      let exchange = raw["exchange"] as? String ?? "NSE"
      let assetType = raw["assetType"] as? String ?? "equity"
      seeds.append(InstrumentState(marketKey: id, fundId: fundId, exchange: exchange,
        assetType: assetType, symbol: symbol, currentLtpMinor: ltp,
        previousLtpMinor: ltp, previousCloseMinor: close, tickSizeMinor: tick))
    }
    queue.async { [weak self] in
      guard let self else { return }
      for seed in seeds { if self.sessionStates[seed.marketKey] == nil { self.sessionStates[seed.marketKey] = seed }; self.activeIds.insert(seed.marketKey) }
      self.ensureTicker(); DispatchQueue.main.async { result(nil) }
    }
  }

  private func unsubscribe(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any], let ids = args["instrumentIds"] as? [String] else {
      result(FlutterError(code: "invalid_unsubscribe", message: "Missing instrumentIds.", details: nil)); return
    }
    queue.async { [weak self] in
      guard let self else { return }; self.activeIds.subtract(ids)
      if self.activeIds.isEmpty { self.stopTicker() }; DispatchQueue.main.async { result(nil) }
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    queue.async { [weak self] in self?.eventSink = events }; return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    queue.async { [weak self] in self?.eventSink = nil }; return nil
  }

  private func ensureTicker() {
    guard !disposed, !paused, !activeIds.isEmpty, timer == nil else { return }
    let source = DispatchSource.makeTimerSource(queue: queue)
    source.schedule(deadline: .now() + 1, repeating: 1, leeway: .milliseconds(50))
    source.setEventHandler { [weak self] in self?.generateTick() }; timer = source; source.resume()
  }
  private func stopTicker() { timer?.setEventHandler {}; timer?.cancel(); timer = nil }

  private func generateTick() {
    guard !disposed, !paused, !activeIds.isEmpty else { return }
    let shuffled = activeIds.shuffled(); let count = Int.random(in: 1...shuffled.count)
    let timestamp = Int64(Date().timeIntervalSince1970 * 1000); batchSequence += 1; let sequence = batchSequence
    var updates: [[String: Any]] = []
    for id in shuffled.prefix(count) {
      guard var state = sessionStates[id] else { continue }; let previous = state.currentLtpMinor
      let roll = Int.random(in: 0..<100)
      let maxTicks: Int64 = (state.assetType == "index" || state.assetType == "marketIndex") ? 4 : 8
      let requested = state.tickSizeMinor * Int64.random(in: 1...maxTicks)
      let delta = min(requested, max(state.tickSizeMinor, previous / 200))
      let next = roll < 15 ? previous : (roll < 58 ? previous + delta : max(state.tickSizeMinor, previous - delta))
      state.previousLtpMinor = previous; state.currentLtpMinor = next; state.lastUpdatedAt = timestamp; state.sequence = sequence; sessionStates[id] = state
      let change = next - state.previousCloseMinor; let direction = next > previous ? "up" : (next < previous ? "down" : "flat")
      updates.append(["marketKey": state.marketKey, "instrumentId": state.marketKey,
        "fundId": state.fundId, "exchange": state.exchange, "assetType": state.assetType,
        "symbol": state.symbol, "ltpMinor": next,
        "previousLtpMinor": previous, "previousCloseMinor": state.previousCloseMinor, "changeMinor": change,
        "changePercent": Double(change) / Double(state.previousCloseMinor) * 100, "direction": direction])
    }
    guard !updates.isEmpty, let sink = eventSink else { return }
    let batch: [String: Any] = ["sequence": sequence, "timestamp": timestamp, "updates": updates]
    DispatchQueue.main.async { [weak self] in if self?.disposed == false { sink(batch) } }
  }

  func dispose() {
    guard !disposed else { return }
    disposed = true
    controlChannel.setMethodCallHandler(nil)
    eventChannel.setStreamHandler(nil)
    queue.async { [weak self] in
      self?.stopTicker()
      self?.eventSink = nil
      self?.activeIds.removeAll()
      self?.sessionStates.removeAll()
    }
  }

  deinit { stopTicker() }
}
