import Foundation

protocol SignInWithEmailInteracorOutput: AnyObject {
    func emailSuccessfullySent()
    func failToSentEmailWith(error: LoginErrorType)
}

final class SignInWithEmailInteracor: NSObject {

    // MARK: - Public properties

    weak var presenter: SignInWithEmailInteracorOutput?

    // MARK: - Private properties

    private let authService: AuthService

    // MARK: - Init

    init(authService: AuthService) {
        self.authService = authService
    }

}

// MARK: - SignInWithEmailInteractorInput
extension SignInWithEmailInteracor: SignInWithEmailInteractorInput {

    func requestTokenWith(email: String) {
        authService.requestTokenWith(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.emailSuccessfullySent()
            case .failure(let error):
                self?.presenter?.failToSentEmailWith(error: .custom(error))
            }
        }
    }

}
