import Foundation
import GoogleSignIn

// MARK: - Local model

enum LoginPresenterState {

    case none
    case failure(PresentableError)
    case workspaces([Workspace])
    case linkHanling(String)
    case signIn

}

protocol LoginViewOutput: ErrorCellDelegate, SignInViewCellDelegate {
    func viewWillAppear()
    func didSelectWorkspace(with id: String)
}

final class LoginPresenter {
    
    // MARK: - Properties
    
    weak var view: LoginViewInput?
    var interactor: LoginInteractorInput?
    var router: LoginRouterInput?
    
    
    // MARK: - Private properties
    
    private var state: LoginPresenterState
    private let provider: LoginContentProvider
    
    
    // MARK: - Init
    
    init(provider: LoginContentProvider, state: LoginPresenterState = .none) {
        self.provider = provider
        self.state = state
    }
    
}


// MARK: - LoginViewOutput
extension LoginPresenter: LoginViewOutput {
 
    func reloadButtonTapped() {
        interactor?.obtainUserStatus(state: state)
    }
    
    func viewWillAppear() {
        
        view?.startAnimating()
        interactor?.obtainUserStatus(state: state)
    }
 
    func didSelectWorkspace(with id: String) {
        
        guard case LoginPresenterState.workspaces(let workspaces) = state,
              let workspace = workspaces.first(where: { $0.id == id }) else { return }
        
        view?.startAnimating()
        interactor?.changeWorkspace(workspace)
    }
    
}


// MARK: - LoginInteractorOutput
extension LoginPresenter: LoginInteractorOutput {
    
    func currentAppVersionIsBlocked() {
        
        let main = LocalizationConfig.main
        
        let model = AlertOkOrCancelModel(title: main.blockingAlertTitle,
                                         subTitle: main.blockingAlertSubTitle,
                                         okActionTitle: main.blockingAlertOkActionTitle,
                                         cancelActionTitle: nil,
                                         okAction: { [weak self] in
            
            self?.router?.openAppStore()
        })
        
        router?.showOkOrCancelAlert(model: model, presenter: .root)
    }
    
    func didObtainWorkspaces(_ workspaces: [Workspace]) {
       
        state = .workspaces(workspaces)
        view?.stopAnimating()
        let viewModel = provider.configurateWorkspace(from: workspaces)
        view?.setupWorkspaceViewModel(viewModel)
    }
    
    func didNotObtainTokenFromStorage() {
        
        state = .signIn
        view?.stopAnimating()
        view?.setupSignInButton()
    }
    
    func didFailToObtainUserStatus(with errorType: LoginErrorType) {
    
        state = .failure(errorType)
        view?.stopAnimating()
        view?.setupWithError(errorType)
    }
    
    func didFinishAuthenticationWithSuccess() {
        
        view?.stopAnimating()
        router?.replaceCurrentViewController()
    }
    
}

// MARK: - SignInViewCellDelegate
extension LoginPresenter {
    
    func didTappedSignInWithEmail() {
        router?.openSignInWithEmail()
    }
}
