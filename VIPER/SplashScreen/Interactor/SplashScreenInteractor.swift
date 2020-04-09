import Foundation

// MARK: - Protocols

protocol SplashScreenInteractorInput: class {
    func initialConfiguration()
}

protocol SplashScreenInteractorOutput: class {
    func failedToConfigurate()
    func successfullyConfigurated()
}

final class SplashScreenInteractor: NSObject {

    // MARK: - Public properties

    weak var presenter: SplashScreenInteractorOutput?

    // MARK: - Private properties

    private let configService: ConfigService
    private let workspaceService: WorkspaceService
    private let keychainService: KeychainService

    // MARK: - Initialization

    init(configService: ConfigService,
         workspaceService: WorkspaceService,
         keychainService: KeychainService) {
        self.configService = configService
        self.workspaceService = workspaceService
        self.keychainService = keychainService
    }

    // MARK: - Private

    private func handle(workspaces: [Workspace]) {

        guard workspaces.count > 1 else {

            if let workspace = workspaces.first {
                changeWorkspace(workspace)
            } else {
                presenter?.failedToConfigurate()
            }

            return
        }

        if let workspaceId = keychainService.getValue(forKey: .workspaceId),
            let workspace = workspaces.first(where: { $0.id == workspaceId } ) {
            changeWorkspace(workspace)
        } else {
            presenter?.failedToConfigurate()
        }
    }

    private func changeWorkspace(_ workspace: Workspace) {

        guard let token = keychainService.getValue(forKey: .apiToken) else {
            presenter?.failedToConfigurate()
            return
        }

        workspaceService.changeWorkspace(to: workspace.id, withToken: token) { [weak self] result in

            switch result {

            case .success(let response):

                self?.keychainService.saveValue(response.token, forKey: .apiToken)
                self?.keychainService.saveValue(workspace.id, forKey: .workspaceId)
                WorkspaceConfig.main.setCurrentWorkspace(workspace)
                self?.presenter?.successfullyConfigurated()

            case .failure:
                self?.presenter?.failedToConfigurate()
            }

        }

    }
}

// MARK: - SplashScreenInteractorInput

extension SplashScreenInteractor: SplashScreenInteractorInput {

    func initialConfiguration() {
        configService.obtainConfig { [weak self] in
            guard !Config.main.isBlocked else {
                self?.presenter?.failedToConfigurate()
                return
            }

            guard
                let token = self?.keychainService.getValue(forKey: .apiToken) else {
                self?.presenter?.failedToConfigurate()
                return
            }

            self?.workspaceService.obtainWorkspaceList(withToken: token, completion: { (result) in
                switch result {
                case .success(let response):
                    self?.handle(workspaces: response)
                case .failure:
                    self?.presenter?.failedToConfigurate()
                }
            })
        }
    }

}
