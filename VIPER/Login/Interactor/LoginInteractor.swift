import Foundation
import GoogleSignIn
import Firebase

protocol LoginInteractorOutput: AnyObject {
    func didFailToObtainUserStatus(with errorType: LoginErrorType)
    func didFinishAuthenticationWithSuccess()
    func didNotObtainTokenFromStorage()
    func didObtainWorkspaces(_ workspaces: [Workspace])
    func currentAppVersionIsBlocked()
}

final class LoginInteractor: NSObject {
    
    // MARK: - Public properties
    
    weak var presenter: LoginInteractorOutput?
    
    
    // MARK: - Private properties
    
    private let googleService: GIDSignIn?
    private let keychainService: KeychainService
    private let authService: AuthService
    private let workspaceService: WorkspaceService
    private let configService: ConfigService
    
    
    // MARK: - Init
    
    init(googleService: GIDSignIn?, keychainService: KeychainService,
         authService: AuthService, workspaceService: WorkspaceService,
         configService: ConfigService) {
       
        self.workspaceService = workspaceService
        self.authService = authService
        self.keychainService = keychainService
        self.googleService = googleService
        self.googleService?.clientID = ServiceUtils.clientId
        self.configService = configService
    }
    
    
    // MARK: - Private methods

    private func handleAuthorization() {
        if let apiToken = keychainService.getValue(forKey: .apiToken) {
            if let signedWithMail: Bool = UserDefaultsUtils.getValueForKey(.signedWithMail),
                signedWithMail {
                refresh(token: apiToken)
            } else {
                googleService?.signIn()
            }
        } else {
            presenter?.didNotObtainTokenFromStorage()
        }
    }

    private func obtainUserToken(_ token: String) {
      
        let fcmToken = Messaging.messaging().fcmToken
        
        authService.authenticate(googleToken: token, fcmToken: fcmToken) { [weak self] result in
            
            switch result {
                
            case .success(let response):
                UserDefaultsUtils.setValueForKey(.signedWithMail, false)
                self?.keychainService.saveValue(response.token, forKey: .apiToken)
                self?.handlingWorkspaces(with: response)
                
            case .failure(let error):
                self?.presenter?.didFailToObtainUserStatus(with: .custom(error))
                
            }
            
        }
        
    }

    private func refresh(token: String) {
        authService.refresh(token: token) { [weak self] (result) in
            switch result {

            case .success(let response):
                UserDefaultsUtils.setValueForKey(.signedWithMail, true)
                self?.keychainService.saveValue(response.token, forKey: .apiToken)
                self?.handlingWorkspaces(with: response)

            case .failure(let error):
                self?.presenter?.didFailToObtainUserStatus(with: .custom(error))

            }
        }
    }

    private func confirmUniversalLink(token: String) {
        let fcmToken = Messaging.messaging().fcmToken

        authService.authenticate(emailToken: token, fcmToken: fcmToken) { [weak self] (result) in
            switch result {

            case .success(let response):
                UserDefaultsUtils.setValueForKey(.signedWithMail, true)
                self?.keychainService.saveValue(response.token, forKey: .apiToken)
                self?.handlingWorkspaces(with: response)

            case .failure(let error):
                self?.presenter?.didFailToObtainUserStatus(with: .custom(error))

            }
        }
    }
 
    private func handlingWorkspaces(with authResponse: AuthenticationResponse) {
        
        guard authResponse.workspaces.count > 1 else {
            
            if let workspace = authResponse.workspaces.first {
                changeWorkspace(workspace)
            } else {
                presenter?.didFailToObtainUserStatus(with: .noWorkspaces)
            }
            
            return
        }
    
        if let workspaceId = keychainService.getValue(forKey: .workspaceId),
            let workspace = authResponse.workspaces.first(where: { $0.id == workspaceId } ) {
            changeWorkspace(workspace)
        } else {
            presenter?.didObtainWorkspaces(authResponse.workspaces)
        }
        
    }
    
    private func generateAnonymityKeyIfNeeded() {
        
        if keychainService.getValue(forKey: .anonymityKey) == nil {
            let newValue = UUID().uuidString
            keychainService.saveValue(newValue, forKey: .anonymityKey)
        }
        
    }
    
}


// MARK: - LoginInteractorInput
extension LoginInteractor: LoginInteractorInput {
   
    func obtainUserStatus(state: LoginPresenterState) {
        
        generateAnonymityKeyIfNeeded()
        
        configService.obtainConfig { [weak self] in
            
            guard !Config.main.isBlocked else {
                self?.presenter?.currentAppVersionIsBlocked()
                return
            }

            switch state {

            case .linkHanling(let token):

                self?.confirmUniversalLink(token: token)

            default:

                self?.handleAuthorization()
                
            }
            
        }
     
    }
    
    func changeWorkspace(_ workspace: Workspace) {
        
        guard let token = keychainService.getValue(forKey: .apiToken) else {
            presenter?.didNotObtainTokenFromStorage()
            return
        }
        
        workspaceService.changeWorkspace(to: workspace.id, withToken: token) { [weak self] result in
            
            switch result {
                
            case .success(let response):
                
                self?.keychainService.saveValue(response.token, forKey: .apiToken)
                self?.keychainService.saveValue(workspace.id, forKey: .workspaceId)
                WorkspaceConfig.main.setCurrentWorkspace(workspace)
                self?.presenter?.didFinishAuthenticationWithSuccess()
                
            case .failure(let error):
                self?.presenter?.didFailToObtainUserStatus(with: .custom(error))
            }
            
        }
        
    }
    
}


// MARK: - GIDSignInDelegate
extension LoginInteractor: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            presenter?.didFailToObtainUserStatus(with: .custom(error))
            return
        }
        
        guard let googleToken = user.authentication.idToken else {
            presenter?.didFailToObtainUserStatus(with: .googleTokenDoesNotExist)
            return
        }
        
        obtainUserToken(googleToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // todo
    }
    
}
