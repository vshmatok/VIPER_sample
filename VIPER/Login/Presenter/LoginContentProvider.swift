import UIKit

protocol LoginContentProvider {
    func configurateWorkspace(from workspaces: [Workspace]) -> WorkspaceItemsViewModel
}

final class LoginContentProviderImp {
 
    // MARK: - Private properties
    
    private let mode: WorkspaceListMode
    
    
    // MARK: - Init
    
    init(mode: WorkspaceListMode) {
        self.mode = mode
    }
    
}


// MARK: - LoginContentProvider
extension LoginContentProviderImp: LoginContentProvider {
    
    func configurateWorkspace(from workspaces: [Workspace]) -> WorkspaceItemsViewModel {
        
        var items: [WorkspaceListItem] = []
        
        let subTitleInsets = UIEdgeInsets(top: 15, left: 0, bottom: 40, right: 0)
        items.append(WorkspaceListItem(type: .subTitle(mode.headerText),
                                       insets: subTitleInsets))
        
        items += workspaces.compactMap({ item in
            
            let model = WorkspaceCollectionCell.Model(id: item.id,
                                                      color: item.config.color,
                                                      name: item.title)
            return .init(.init(type: .item(model: model), insets: .zero))
        })
        
        return WorkspaceItemsViewModel(title: mode.navigationTitle, items: items)
    }
    
}

