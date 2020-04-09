import UIKit

final class SignInWithEmailAssembly: Assembly {

    static func assembleModule() -> ModuleTransitionHandler {

        let view = SignInWithEmailViewController()

        let networkClient = NetworkClient()
        let authService = AuthServiceImp(networkClient: networkClient)

        let interactor = SignInWithEmailInteracor(authService: authService)

        let presenter = SignInWithEmailPresenter()
        let router = SignInWithEmailRouter()
        router.view = view

        interactor.presenter = presenter

        presenter.router = router
        presenter.interactor = interactor
        presenter.view = view

        view.presenter = presenter

        return view
    }

}
