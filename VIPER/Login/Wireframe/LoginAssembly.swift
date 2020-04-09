import GoogleSignIn

final class LoginAssembly {
    
    static func assembleModule(with appDelegate: AppDelegateInput, state: LoginPresenterState = .none) -> UIViewController {
        
        let view = LoginViewController()
        
        let googleService = GIDSignIn.sharedInstance()
        let keychainService = KeychainServiceImp()
        let networkClient = NetworkClient()
        let authService = AuthServiceImp(networkClient: networkClient)
        let workspaceService = WorkspaceServiceImp(networkClient: networkClient)
        let provider = LoginContentProviderImp(mode: .change)
        let configService = ConfigServiceImp(networkClient: networkClient)
        
        let interactor = LoginInteractor(googleService: googleService,
                                         keychainService: keychainService,
                                         authService: authService,
                                         workspaceService: workspaceService,
                                         configService: configService)
        let presenter = LoginPresenter(provider: provider, state: state)
        let router = LoginRouter(appDelegate: appDelegate)
        router.view = view
        
        googleService?.uiDelegate = view
        googleService?.delegate = interactor
        
        interactor.presenter = presenter
        
        presenter.router = router
        presenter.interactor = interactor
        presenter.view = view
        
        view.presenter = presenter
        
        return view.wrappedInNavigationController()
    }
    
}
