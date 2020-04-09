import UIKit

final class SplashScreenViewController: UIViewController {

    // MARK: - Public properties

    var presenter: SplashScreenViewOutput?

    var loadingIndicator: LoadingIndicator = CometGrapeLoaderView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        drawSelf()
        presenter?.viewDidLoad()
    }

    // MARK: - Drawing

    private func drawSelf() {
        view.backgroundColor = Colors.backgroundColor
        
        view.addSubview(loadingIndicator.view)
        loadingIndicator.view.autoCenterInSuperview()

        loadingIndicator.start()
    }

}
