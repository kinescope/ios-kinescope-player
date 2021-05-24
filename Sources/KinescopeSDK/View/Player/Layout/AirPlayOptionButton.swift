//
//  AirPlayOptionButton.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 13.04.2021.
//

import MediaPlayer

/// MPVolumeView button wrapper view
/// Also observes AirPlay statuses to change ui
final class AirPlayOptionButton: UIButton {

    // MARK: - Init and deinit

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

private extension AirPlayOptionButton {

    func setupInitialState() {
        let volumeView = MPVolumeView()
        volumeView.showsVolumeSlider = false
        volumeView.setRouteButtonImage(UIImage.image(named: getImageName(for: volumeView)), for: .normal)
        addSubview(volumeView)
        stretch(view: volumeView)
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
