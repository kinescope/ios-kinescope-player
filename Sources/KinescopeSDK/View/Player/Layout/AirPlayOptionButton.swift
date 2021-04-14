//
//  AirPlayOptionButton.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 13.04.2021.
//

import AVKit
import MediaPlayer

final class AirPlayOptionButton: UIButton {

    init() {
        super.init(frame: .zero)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private Methods

private extension AirPlayOptionButton {

    func setupInitialState() {
        if #available(iOS 11.0, *) {
            let picker = AVRoutePickerView()
            picker.tintColor = .yellow
            picker.activeTintColor = .yellow
            addSubview(picker)
            stretch(view: picker)
        } else {
            let volumeView = MPVolumeView()
            volumeView.showsVolumeSlider = false
            volumeView.setRouteButtonImage(UIImage.image(named: "airPlay"), for: .normal)
            addSubview(volumeView)
            volumeView.center = center
        }
    }

}
