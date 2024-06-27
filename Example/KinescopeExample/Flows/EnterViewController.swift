//
//  EnterViewController.swift
//  KinescopeExample
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import UIKit

final class EnterViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var uiSwitch: UISwitch!

    // MARK: - Private properties

    // Change this id to your video id from dashboard. This one is free video for demo of SDK only.
    private let initialVideoId: String = {
#if targetEnvironment(simulator)
        "9L8KmbNuhQSxQofn5DR4Vg"
#else
        "b6a0ce69-3135-496d-8064-c8ed51ac4b2e"
#endif
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        field.text = initialVideoId
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Player",
              let destination = segue.destination as? VideoViewController,
              let videoId = sender as? String else {
            return
        }
        destination.videoId = videoId
        destination.uiEnabled = uiSwitch.isOn
    }

    // MARK: - Actions

    @IBAction func didTapPlay(_ sender: Any) {
        tryToPlay()
    }
    
}

// MARK: - Private

private extension EnterViewController {
    
    func tryToPlay() {
        if let videoId = field.text?.trimmingCharacters(in: .whitespacesAndNewlines), !videoId.isEmpty {
            showPlayer(for: videoId)
        } else {
            showAlert()
        }
    }

    func showPlayer(for videoId: String) {
        performSegue(withIdentifier: "Player", sender: videoId)
    }

    func showAlert() {
        let alert = UIAlertController(title: "Error",
                                      message: "videoId should not be empty",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }

}
