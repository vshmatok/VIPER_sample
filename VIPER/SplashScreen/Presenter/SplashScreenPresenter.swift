import UIKit

// MARK: - Protocols

protocol SplashScreenViewOutput: class {
    func viewDidLoad()
}

final class SplashScreenPresenter {

    // MARK: - State

    private enum State {
        case openPollDetail(workspaceId: String, pollId: String)
        case `default`
    }

    // MARK: - Properties

    var interactor: SplashScreenInteractorInput?
    var router: SplashScreenRouterInput?

    private var pushNotificationConverter: PushNotificationDataConverterInput

    private var state: State = .default

    // MARK: - Init

    init(pushNotificationDataConverter: PushNotificationDataConverterInput, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.pushNotificationConverter = pushNotificationDataConverter

        if let remoteNotificationData = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            handle(notificationInfo: remoteNotificationData)
        }

    }

    // MARK: - Private

    private func handle(notificationInfo: [String: Any]) {
        if let type = pushNotificationConverter.getPushType(notificationInfo: notificationInfo) {
            switch type {
            case .pollDetail(let workspaceId, let pollId):
                state = .openPollDetail(workspaceId: workspaceId, pollId: pollId)
            }
        }
    }
}

// MARK: - SplashScreenViewOutput

extension SplashScreenPresenter: SplashScreenViewOutput {

    func viewDidLoad() {
        interactor?.initialConfiguration()
    }
}

// MARK: - SplashScreenInteractorOutput

extension SplashScreenPresenter: SplashScreenInteractorOutput {

    func failedToConfigurate() {
        router?.switchToLoginRoot()
    }

    func successfullyConfigurated() {
        switch state {
        case .openPollDetail(let workspaceId, let pollId):
            router?.openPollDetailScreen(workspaceId: workspaceId, pollId: pollId)
        case .default:
            router?.switchToPollRoot()
        }
    }
}
