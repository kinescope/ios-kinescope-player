//
//  AirPlayOptionControl.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 13.04.2021.
//

import AVKit
import MediaPlayer

final class AirPlayOptionControl: UIControl {

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupInitialState()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didAirPlayStateChanged),
                                               name: .MPVolumeViewWirelessRouteActiveDidChange,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Private Methods

private extension AirPlayOptionControl {

    func setupInitialState() {
        let systemView: UIView
        if #available(iOS 11.0, *) {
            let routePickerView = AVRoutePickerView()
            if #available(iOS 13.0, *) {
                routePickerView.prioritizesVideoDevices = true
            }
            systemView = routePickerView
        } else {
            let volumeView = MPVolumeView(frame: .zero)
            volumeView.showsVolumeSlider = false
            volumeView.setRouteButtonImage(UIImage.image(named: getImageName(for: volumeView)), for: .normal)
            systemView = volumeView
        }

        addSubview(systemView)
        stretch(view: systemView)
    }

    func getImageName(for volumeView: MPVolumeView) -> String {
        return volumeView.isWirelessRouteActive ? "airPlayActive" : "airPlay"
    }

    @objc
    func didAirPlayStateChanged(_ notification: NSNotification) {
        guard let volumeView = notification.object as? MPVolumeView else {
            return
        }
        volumeView.setRouteButtonImage(UIImage.image(named: getImageName(for: volumeView)), for: .normal)
    }

}
