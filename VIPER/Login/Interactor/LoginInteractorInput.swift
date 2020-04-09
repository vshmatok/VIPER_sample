import Foundation

protocol LoginInteractorInput {
    func obtainUserStatus(state: LoginPresenterState)
    func changeWorkspace(_ workspace: Workspace)
}
