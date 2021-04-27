// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: events.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum Analytics_SessionType: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case online // = 0
  case offline // = 1
  case UNRECOGNIZED(Int)

  init() {
    self = .online
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .online
    case 1: self = .offline
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .online: return 0
    case .offline: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Analytics_SessionType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Analytics_SessionType] = [
    .online,
    .offline,
  ]
}

#endif  // swift(>=4.2)

struct Analytics_Player {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// iOS SDK
  var type: String = String()

  /// 1.2.42
  var version: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Analytics_Video {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// https://kinescopecdn.net/xxx-xxx/xxx-xxx/video.mp4
  var source: String = String()

  /// 120 (seconds)
  var duration: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Analytics_Playback {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var rate: Float = 0

  /// 0-100
  var volume: Int32 = 0

  /// 480p/720p/1080p ...
  var quality: String = String()

  var isMuted: Bool = false

  var isFullscreen: Bool = false

  /// 120 (seconds)
  var previewPosition: UInt32 = 0

  /// 125 (seconds)
  var currentPosition: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Analytics_Device {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var os: String = String()

  var osversion: String = String()

  var screenWidth: UInt32 = 0

  var screenHeight: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Analytics_Session {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: Data = Data()

  var type: Analytics_SessionType = .online

  var viewID: Data = Data()

  var ipaddress: Data = Data()

  var externalID: String = String()

  var watchedDuration: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Analytics_Native {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var event: String {
    get {return _storage._event}
    set {_uniqueStorage()._event = newValue}
  }

  var value: Float {
    get {return _storage._value}
    set {_uniqueStorage()._value = newValue}
  }

  var video: Analytics_Video {
    get {return _storage._video ?? Analytics_Video()}
    set {_uniqueStorage()._video = newValue}
  }
  /// Returns true if `video` has been explicitly set.
  var hasVideo: Bool {return _storage._video != nil}
  /// Clears the value of `video`. Subsequent reads from it will return its default value.
  mutating func clearVideo() {_uniqueStorage()._video = nil}

  var player: Analytics_Player {
    get {return _storage._player ?? Analytics_Player()}
    set {_uniqueStorage()._player = newValue}
  }
  /// Returns true if `player` has been explicitly set.
  var hasPlayer: Bool {return _storage._player != nil}
  /// Clears the value of `player`. Subsequent reads from it will return its default value.
  mutating func clearPlayer() {_uniqueStorage()._player = nil}

  var device: Analytics_Device {
    get {return _storage._device ?? Analytics_Device()}
    set {_uniqueStorage()._device = newValue}
  }
  /// Returns true if `device` has been explicitly set.
  var hasDevice: Bool {return _storage._device != nil}
  /// Clears the value of `device`. Subsequent reads from it will return its default value.
  mutating func clearDevice() {_uniqueStorage()._device = nil}

  var session: Analytics_Session {
    get {return _storage._session ?? Analytics_Session()}
    set {_uniqueStorage()._session = newValue}
  }
  /// Returns true if `session` has been explicitly set.
  var hasSession: Bool {return _storage._session != nil}
  /// Clears the value of `session`. Subsequent reads from it will return its default value.
  mutating func clearSession() {_uniqueStorage()._session = nil}

  var playback: Analytics_Playback {
    get {return _storage._playback ?? Analytics_Playback()}
    set {_uniqueStorage()._playback = newValue}
  }
  /// Returns true if `playback` has been explicitly set.
  var hasPlayback: Bool {return _storage._playback != nil}
  /// Clears the value of `playback`. Subsequent reads from it will return its default value.
  mutating func clearPlayback() {_uniqueStorage()._playback = nil}

  var eventTime: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _storage._eventTime ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_uniqueStorage()._eventTime = newValue}
  }
  /// Returns true if `eventTime` has been explicitly set.
  var hasEventTime: Bool {return _storage._eventTime != nil}
  /// Clears the value of `eventTime`. Subsequent reads from it will return its default value.
  mutating func clearEventTime() {_uniqueStorage()._eventTime = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "analytics"

extension Analytics_SessionType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Online"),
    1: .same(proto: "Offline"),
  ]
}

extension Analytics_Player: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Player"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Type"),
    2: .same(proto: "Version"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.type) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.version) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.type.isEmpty {
      try visitor.visitSingularStringField(value: self.type, fieldNumber: 1)
    }
    if !self.version.isEmpty {
      try visitor.visitSingularStringField(value: self.version, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Player, rhs: Analytics_Player) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.version != rhs.version {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Analytics_Video: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Video"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Source"),
    2: .same(proto: "Duration"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.source) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.duration) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.source.isEmpty {
      try visitor.visitSingularStringField(value: self.source, fieldNumber: 1)
    }
    if self.duration != 0 {
      try visitor.visitSingularUInt32Field(value: self.duration, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Video, rhs: Analytics_Video) -> Bool {
    if lhs.source != rhs.source {return false}
    if lhs.duration != rhs.duration {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Analytics_Playback: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Playback"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Rate"),
    2: .same(proto: "Volume"),
    3: .same(proto: "Quality"),
    4: .same(proto: "IsMuted"),
    5: .same(proto: "IsFullscreen"),
    6: .same(proto: "PreviewPosition"),
    7: .same(proto: "CurrentPosition"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularFloatField(value: &self.rate) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.volume) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.quality) }()
      case 4: try { try decoder.decodeSingularBoolField(value: &self.isMuted) }()
      case 5: try { try decoder.decodeSingularBoolField(value: &self.isFullscreen) }()
      case 6: try { try decoder.decodeSingularUInt32Field(value: &self.previewPosition) }()
      case 7: try { try decoder.decodeSingularUInt32Field(value: &self.currentPosition) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.rate != 0 {
      try visitor.visitSingularFloatField(value: self.rate, fieldNumber: 1)
    }
    if self.volume != 0 {
      try visitor.visitSingularInt32Field(value: self.volume, fieldNumber: 2)
    }
    if !self.quality.isEmpty {
      try visitor.visitSingularStringField(value: self.quality, fieldNumber: 3)
    }
    if self.isMuted != false {
      try visitor.visitSingularBoolField(value: self.isMuted, fieldNumber: 4)
    }
    if self.isFullscreen != false {
      try visitor.visitSingularBoolField(value: self.isFullscreen, fieldNumber: 5)
    }
    if self.previewPosition != 0 {
      try visitor.visitSingularUInt32Field(value: self.previewPosition, fieldNumber: 6)
    }
    if self.currentPosition != 0 {
      try visitor.visitSingularUInt32Field(value: self.currentPosition, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Playback, rhs: Analytics_Playback) -> Bool {
    if lhs.rate != rhs.rate {return false}
    if lhs.volume != rhs.volume {return false}
    if lhs.quality != rhs.quality {return false}
    if lhs.isMuted != rhs.isMuted {return false}
    if lhs.isFullscreen != rhs.isFullscreen {return false}
    if lhs.previewPosition != rhs.previewPosition {return false}
    if lhs.currentPosition != rhs.currentPosition {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Analytics_Device: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Device"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "OS"),
    2: .same(proto: "OSVersion"),
    3: .same(proto: "ScreenWidth"),
    4: .same(proto: "ScreenHeight"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.os) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.osversion) }()
      case 3: try { try decoder.decodeSingularUInt32Field(value: &self.screenWidth) }()
      case 4: try { try decoder.decodeSingularUInt32Field(value: &self.screenHeight) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.os.isEmpty {
      try visitor.visitSingularStringField(value: self.os, fieldNumber: 1)
    }
    if !self.osversion.isEmpty {
      try visitor.visitSingularStringField(value: self.osversion, fieldNumber: 2)
    }
    if self.screenWidth != 0 {
      try visitor.visitSingularUInt32Field(value: self.screenWidth, fieldNumber: 3)
    }
    if self.screenHeight != 0 {
      try visitor.visitSingularUInt32Field(value: self.screenHeight, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Device, rhs: Analytics_Device) -> Bool {
    if lhs.os != rhs.os {return false}
    if lhs.osversion != rhs.osversion {return false}
    if lhs.screenWidth != rhs.screenWidth {return false}
    if lhs.screenHeight != rhs.screenHeight {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Analytics_Session: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Session"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ID"),
    2: .same(proto: "Type"),
    3: .same(proto: "ViewID"),
    4: .same(proto: "IPaddress"),
    5: .same(proto: "ExternalID"),
    6: .same(proto: "WatchedDuration"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.id) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.viewID) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.ipaddress) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.externalID) }()
      case 6: try { try decoder.decodeSingularUInt32Field(value: &self.watchedDuration) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.id.isEmpty {
      try visitor.visitSingularBytesField(value: self.id, fieldNumber: 1)
    }
    if self.type != .online {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 2)
    }
    if !self.viewID.isEmpty {
      try visitor.visitSingularBytesField(value: self.viewID, fieldNumber: 3)
    }
    if !self.ipaddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.ipaddress, fieldNumber: 4)
    }
    if !self.externalID.isEmpty {
      try visitor.visitSingularStringField(value: self.externalID, fieldNumber: 5)
    }
    if self.watchedDuration != 0 {
      try visitor.visitSingularUInt32Field(value: self.watchedDuration, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Session, rhs: Analytics_Session) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.type != rhs.type {return false}
    if lhs.viewID != rhs.viewID {return false}
    if lhs.ipaddress != rhs.ipaddress {return false}
    if lhs.externalID != rhs.externalID {return false}
    if lhs.watchedDuration != rhs.watchedDuration {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Analytics_Native: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Native"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Event"),
    2: .same(proto: "Value"),
    3: .same(proto: "Video"),
    4: .same(proto: "Player"),
    5: .same(proto: "Device"),
    6: .same(proto: "Session"),
    7: .same(proto: "Playback"),
    8: .same(proto: "EventTime"),
  ]

  fileprivate class _StorageClass {
    var _event: String = String()
    var _value: Float = 0
    var _video: Analytics_Video? = nil
    var _player: Analytics_Player? = nil
    var _device: Analytics_Device? = nil
    var _session: Analytics_Session? = nil
    var _playback: Analytics_Playback? = nil
    var _eventTime: SwiftProtobuf.Google_Protobuf_Timestamp? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _event = source._event
      _value = source._value
      _video = source._video
      _player = source._player
      _device = source._device
      _session = source._session
      _playback = source._playback
      _eventTime = source._eventTime
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularStringField(value: &_storage._event) }()
        case 2: try { try decoder.decodeSingularFloatField(value: &_storage._value) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._video) }()
        case 4: try { try decoder.decodeSingularMessageField(value: &_storage._player) }()
        case 5: try { try decoder.decodeSingularMessageField(value: &_storage._device) }()
        case 6: try { try decoder.decodeSingularMessageField(value: &_storage._session) }()
        case 7: try { try decoder.decodeSingularMessageField(value: &_storage._playback) }()
        case 8: try { try decoder.decodeSingularMessageField(value: &_storage._eventTime) }()
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._event.isEmpty {
        try visitor.visitSingularStringField(value: _storage._event, fieldNumber: 1)
      }
      if _storage._value != 0 {
        try visitor.visitSingularFloatField(value: _storage._value, fieldNumber: 2)
      }
      if let v = _storage._video {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if let v = _storage._player {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
      if let v = _storage._device {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      }
      if let v = _storage._session {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      }
      if let v = _storage._playback {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
      }
      if let v = _storage._eventTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Analytics_Native, rhs: Analytics_Native) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._event != rhs_storage._event {return false}
        if _storage._value != rhs_storage._value {return false}
        if _storage._video != rhs_storage._video {return false}
        if _storage._player != rhs_storage._player {return false}
        if _storage._device != rhs_storage._device {return false}
        if _storage._session != rhs_storage._session {return false}
        if _storage._playback != rhs_storage._playback {return false}
        if _storage._eventTime != rhs_storage._eventTime {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
