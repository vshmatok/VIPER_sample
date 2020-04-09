import Foundation

protocol SignInWithEmailViewOutput: SignInWithEmailTableViewCellDelegate {
}

final class SignInWithEmailPresenter {

    // MARK: - Properties

    weak var view: SignInWithEmailViewInput?
    var interactor: SignInWithEmailInteractorInput?
    var router: SignInWithEmailRouter?

    // MARK: - Private methods

    private func showFailAlert() {
        let main = LocalizationConfig.main.signInWithEmailAlertFailTitle
        let substitle = LocalizationConfig.main.signInWithEmailAlertFailSubtitle
        let cancelText = LocalizationConfig.main.profileAlertCancelActionTitle
        let okText = LocalizationConfig.main.signInWithEmailAlertFailOkButtonTitle
        let model = AlertOkOrCancelModel(title: main,
                                         subTitle: substitle,
                                         okActionTitle: okText,
                                         cancelActionTitle: cancelText,
                                         okAction: { [weak self] in
                                            self?.retryEmail()
        })

        router?.showOkOrCancelAlert(model: model, presenter: .root)
    }

    private func showSuccessAlert() {
        let main = LocalizationConfig.main.signInWithEmailAlertSuccessTitle
        let substitle = LocalizationConfig.main.signInWithEmailAlertSuccessSubtitle
        let cancelText = LocalizationConfig.main.signInWithEmailAlertButtonOk
        let okText = LocalizationConfig.main.signInWithEmailAlertButtonMail

        let model = AlertOkOrCancelModel(title: main,
                                         subTitle: substitle,
                                         okActionTitle: okText,
                                         cancelActionTitle: cancelText,
                                         okAction: { [weak self] in
                                            self?.openMail()
        })

        router?.showOkOrCancelAlert(model: model, presenter: .root)
    }

    private func retryEmail() {
        guard let email: String = UserDefaultsUtils.getValueForKey(.lastSavedMail) else { return }
        view?.startAnimating()
        interactor?.requestTokenWith(email: email)
    }

    private func openMail() {
        guard let mailURL = URL(string: "message://") else {
            return
        }
        view?.open(URL: mailURL)
    }
}

// MARK: - SignInWithEmailInteracorOutput
extension SignInWithEmailPresenter: SignInWithEmailInteracorOutput {

    func emailSuccessfullySent() {
        view?.stopAnimating()
        view?.clearTextField()
        showSuccessAlert()
    }

    func failToSentEmailWith(error: LoginErrorType) {
        view?.stopAnimating()
        showFailAlert()
    }
}

// MARK: - SignInWithEmailTableViewCellDelegate

extension SignInWithEmailPresenter: SignInWithEmailViewOutput {
    func didTappedGetLinkButtonWith(email: String) {
        UserDefaultsUtils.setValueForKey(.lastSavedMail, email)
        view?.startAnimating()
        interactor?.requestTokenWith(email: email)
    }
}
