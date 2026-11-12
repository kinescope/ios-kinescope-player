//
//  AirPlayOptionControl.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 13.04.2021.
//

import AVFoundation
import AVKit
import MediaPlayer

/// AirPlay route button. The system glyph is a bare screen-and-triangle outline,
/// so the control draws the same icon as the rest of the player chrome.
final class AirPlayOptionControl: UIControl {

    private let routePicker: UIView
    private let iconView = UIImageView()

    // MARK: - Initialization

    init() {
        if #available(iOS 11.0, *) {
            let picker = AVRoutePickerView()
            if #available(iOS 13.0, *) {
                picker.prioritizesVideoDevices = true
                picker.activeTintColor = .clear
            }
            picker.tintColor = .clear
            routePicker = picker
        } else {
            let volumeView = MPVolumeView(frame: .zero)
            volumeView.showsVolumeSlider = false
            routePicker = volumeView
        }

        super.init(frame: .zero)
        setupInitialState()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(routeChanged),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(routeChanged),
                                               name: .MPVolumeViewWirelessRouteActiveDidChange,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        iconView.tintColor = tintColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyIcon()
    }

    /// The glyph stays 24 pt. Taps on the padding around it still open the route picker.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard bounds.contains(point) else {
            return nil
        }
        let local = convert(point, to: routePicker)
        if let hit = routePicker.hitTest(local, with: event) {
            return hit
        }
        return routePicker.hitTest(CGPoint(x: routePicker.bounds.midX, y: routePicker.bounds.midY), with: event)
    }

}

// MARK: - Private Methods

private extension AirPlayOptionControl {

    func setupInitialState() {
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        iconView.tintColor = tintColor

        addSubview(routePicker)
        addSubview(iconView)
        routePicker.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            routePicker.centerXAnchor.constraint(equalTo: centerXAnchor),
            routePicker.centerYAnchor.constraint(equalTo: centerYAnchor),
            routePicker.widthAnchor.constraint(equalToConstant: 24),
            routePicker.heightAnchor.constraint(equalToConstant: 24),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        applyIcon()
    }

    func applyIcon() {
        let image = UIImage.image(named: isAirPlayActive ? "airPlayActive" : "airPlay")
            .withRenderingMode(.alwaysTemplate)
        iconView.image = image
        iconView.tintColor = tintColor
        replaceSystemGlyph(with: image)
    }

    func replaceSystemGlyph(with image: UIImage) {
        func walk(_ view: UIView) {
            if let button = view as? UIButton {
                button.setImage(image, for: .normal)
                button.setImage(image, for: .highlighted)
                button.setImage(image, for: .selected)
                button.tintColor = tintColor
            }
            view.subviews.forEach(walk)
        }
        walk(routePicker)
    }

    var isAirPlayActive: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .airPlay }
    }

    @objc
    func routeChanged() {
        applyIcon()
    }

}
