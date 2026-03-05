import UIKit
import KinescopeSDK

final class DownloadedListViewController: UIViewController {

    private var videoIds: [String] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Downloaded", comment: "")
        view.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadList()
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    private func reloadList() {
        videoIds = Kinescope.shared.videoDownloader.downloadedList()
        tableView.reloadData()
    }

    private func playVideo(videoId: String) {
        guard let url = Kinescope.shared.videoDownloader.getLocation(by: videoId) else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("File not found.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Could not open player.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
            return
        }
        vc.videoId = videoId
        vc.localVideoURL = url
        vc.uiEnabled = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func deleteVideo(videoId: String, at indexPath: IndexPath) {
        let deleted = Kinescope.shared.videoDownloader.delete(videoId: videoId)
        if deleted {
            videoIds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Could not delete video.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
        }
    }
}

extension DownloadedListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = videoIds[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        let deleteButton = makeDeleteButton(for: indexPath)
        let stack = UIStackView(arrangedSubviews: [deleteButton, makeDisclosureView()])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        cell.accessoryView = stack
        return cell
    }

    private func makeDeleteButton(for indexPath: IndexPath) -> UIButton {
        let button = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            button.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        }
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func makeDisclosureView() -> UIView {
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let imageView = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
            imageView.tintColor = .tertiaryLabel
            return imageView
        }
        return UIView()
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        guard row >= 0, row < videoIds.count else { return }
        let videoId = videoIds[row]
        let indexPath = IndexPath(row: row, section: 0)
        let alert = UIAlertController(
            title: NSLocalizedString("Delete", comment: ""),
            message: NSLocalizedString("Remove this video from device?", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.deleteVideo(videoId: videoId, at: indexPath)
        })
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playVideo(videoId: videoIds[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteVideo(videoId: videoIds[indexPath.row], at: indexPath)
        }
    }
}
