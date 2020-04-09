import UIKit

protocol LoginRouterInput: AlertViewRoutable {
    func replaceCurrentViewController()
    func openAppStore()
    func openSignInWithEmail()
}

final class LoginRouter {
    
    // MARK: - Private properties
    
    weak var view: ModuleTransitionHandler?
    private weak var appDelegate: AppDelegateInput?
    
    
    // MARK: - Init
    
    init(appDelegate: AppDelegateInput) {
        self.appDelegate = appDelegate
    }
    
}


// MARK: - LoginRouterInput
extension LoginRouter: LoginRouterInput {
    
    func openAppStore() {
   
        if let url = URL(string: "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
       
    }
        
    func replaceCurrentViewController() {
        appDelegate?.replaceRootViewController(on: .tabbar)
    }

    func openSignInWithEmail() {
        view?.push(moduleType: SignInWithEmailAssembly.self)
    }
}
