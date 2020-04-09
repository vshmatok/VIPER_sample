import UIKit

final class SplashScreenAssembly {

    static func assemblyModule(with appDelegate: AppDelegateInput, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UIViewController {

        let view = SplashScreenViewController()

        let keychainService = KeychainServiceImp()
        let networkClient = NetworkClient()
        let dataConverter = PushNotificationDataConverter()
        let workspaceService = WorkspaceServiceImp(networkClient: networkClient)
        let configService = ConfigServiceImp(networkClient: networkClient)

        let interactor = SplashScreenInteractor(configService: configService, workspaceService: workspaceService, keychainService: keychainService)

        let presenter = SplashScreenPresenter(pushNotificationDataConverter: dataConverter, launchOptions: launchOptions)
        let router = SplashScreenRouter(appDelegate: appDelegate)

        view.presenter = presenter

        interactor.presenter = presenter

        presenter.router = router
        presenter.interactor = interactor

        return view
    }
}
