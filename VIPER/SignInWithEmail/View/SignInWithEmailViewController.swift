import UIKit

protocol SignInWithEmailViewInput: AnyObject {
    func startAnimating()
    func stopAnimating()
    func clearTextField()
    func open(URL: URL)
}

final class SignInWithEmailViewController: UIViewController, NavBarSetupable {

    // MARK: - Properties

    var presenter: SignInWithEmailViewOutput?

    // MARK: - Private properties

    private let tableView = UITableView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        drawSelf()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupNavigationBarColor()
    }

    // MARK: - Drawing

    private func drawSelf() {

        setupNavigationBar()
        setupNavigationBarColor(.white)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = LocalizationConfig.main.signInWithEmailNavigationBarText

        view.backgroundColor = .white
        tableView.backgroundColor = .clear
        tableView.register(cellTypes: SignInWithEmailTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
    }

}

// MARK: - UITableViewDataSource
extension SignInWithEmailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SignInWithEmailTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.selectionStyle = .none
        cell.delegate = presenter
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SignInWithEmailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = InterfaceUtils.screenHeight
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

// MARK: - SignInWithEmailViewInput
extension SignInWithEmailViewController: SignInWithEmailViewInput {

    func open(URL: URL) {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
    }

    func startAnimating() {

        let cell = tableView.visibleCells.first { $0 is Loadable }
        (cell as? SignInWithEmailCellViewOutput)?.startAnimating()
    }

    func stopAnimating() {

        let cell = tableView.visibleCells.first { $0 is Loadable }
        (cell as? SignInWithEmailCellViewOutput)?.stopAnimating()
    }

    func clearTextField() {

        let cell = tableView.visibleCells.first { $0 is Loadable }
        (cell as? SignInWithEmailCellViewOutput)?.clearTextField()

    }

}
