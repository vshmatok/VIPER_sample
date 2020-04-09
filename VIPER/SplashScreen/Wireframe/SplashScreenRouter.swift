import UIKit

protocol SplashScreenRouterInput: PushNotificationsRouterInput {
    func switchToLoginRoot()
    func switchToPollRoot()
}

final class SplashScreenRouter: PushNotificationsRouter {

    // MARK: - Init

    override init(appDelegate: AppDelegateInput) {
        super.init(appDelegate: appDelegate)
    }

}

// MARK: - SplashScreenRouterInput

extension SplashScreenRouter: SplashScreenRouterInput {

    func switchToLoginRoot() {
        appDelegate?.replaceRootViewController(on: .login)
    }

    func switchToPollRoot() {
        appDelegate?.replaceRootViewController(on: .tabbar)
    }

}
