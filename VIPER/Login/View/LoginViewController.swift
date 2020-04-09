import UIKit
import GoogleSignIn

protocol LoginViewInput: Loadable {
    func setupSignInButton()
    func setupWorkspaceViewModel(_ viewModel: WorkspaceItemsViewModel)
    func setupWithError(_ error: PresentableError)
}

final class LoginViewController: UIViewController, GIDSignInUIDelegate, NavBarSetupable {
    
    // MARK: - Local model
    
    private enum State {
        
        case none
        case signIn
        case selectWorkspace(items: [WorkspaceListItem])
        case failure
        
    }
    
    
    // MARK: - Public properties
    
    var loadingIndicator: LoadingIndicator = CometGrapeLoaderView()
    var presenter: LoginViewOutput?
    
    
    // MARK: - Private properties
    
    private let collectionView = UICollectionView(scrollDirection: .vertical)
    private let errorProvider = ErrorMessageProviderImp()
    private var state: State = .none
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawSelf()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
    
    
    // MARK: - Drawing
    
    private func drawSelf() {
        
        setupNavigationBar()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = Colors.backgroundColor
        errorProvider.delegate = presenter
        
        collectionView.backgroundColor = .clear
        collectionView.register(cellTypes: ErrorMessageCell.self,
                                           UICollectionViewCell.self,
                                           SignInViewCell.self,
                                           PollTextCell.self,
                                           WorkspaceCollectionCell.self,
                                           ErrorMessageCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false

        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()

        view.addSubview(loadingIndicator.view)
        loadingIndicator.view.autoCenterInSuperview()
        
    }
    
}


// MARK: - UICollectionViewDataSource
extension LoginViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        switch state {
        case .none:
            return 1
            
        case .selectWorkspace(let items):
            return items.count
            
        case .signIn, .failure:
            return 1
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch state {
            
        case .failure:
            return errorProvider.createCell(with: collectionView, at: indexPath)
            
        case .none:
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell

        case .selectWorkspace(let items):
            
            let item = items[indexPath.section]
            
            switch item.type {
     
            case .subTitle(let text):
                let cell: PollTextCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.setText(text)
                cell.setFont(item.type.font)
                cell.setTextColor(item.type.textColor)
                
                return cell
                
            case .item(let model):
                let cell: WorkspaceCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: model)
                return cell
                
            }
            
        case .signIn:
            let cell: SignInViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.delegate = presenter
            return cell
        }
        
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension LoginViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch state {
        case .none:
            return InterfaceUtils.screenBounds.size
            
        case .selectWorkspace(let items):
            return items[indexPath.section].type.size
            
        case .signIn, .failure:
            let height = InterfaceUtils.screenHeight 
            return CGSize(width: InterfaceUtils.screenWidth, height: height)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch state {
        case .selectWorkspace(let items):
            return items[section].insets
            
        case .none, .signIn, .failure:
            return .zero
        }
        
    }
    
}


// MARK: - UICollectionViewDelegate
extension LoginViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard case State.selectWorkspace(let items) = state,
              case WorkspaceListItem.CellType.item(let model) = items[indexPath.section].type else {
            return
        }

        presenter?.didSelectWorkspace(with: model.id)
    }
    
}


// MARK: - LoginViewInput
extension LoginViewController: LoginViewInput {
  
    func setupWithError(_ error: PresentableError) {
        
        state = .failure
        errorProvider.setupError(error)
        errorProvider.refreshErrorCell(with: collectionView)
        
    }
    
  
    func setupWorkspaceViewModel(_ viewModel: WorkspaceItemsViewModel) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = viewModel.title
    
        errorProvider.setupToNoneState()
        state = .selectWorkspace(items: viewModel.items)
        collectionView.reloadData()
    }
    
    func setupSignInButton() {

        errorProvider.setupToNoneState()
        state = .signIn
        collectionView.reloadData()
    }
    
}


