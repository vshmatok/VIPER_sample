import Foundation

enum LoginErrorType: PresentableError {

    case noWorkspaces
    case googleTokenDoesNotExist
    case custom(Error)
    
    var userMessage: String {
        
        switch self {
            
        case .noWorkspaces:
            return LocalizationConfig.main.splashNoWorkspacesErrorTitle
            
        case .googleTokenDoesNotExist:
            return LocalizationConfig.main.splashGoogleTokenDoesNotExistErrorTitle
            
        case .custom(let error):
            return error.localizedDescription
   
        }
        
    }
    
    var isNetworkError: Bool {
        
        switch self {
        case .googleTokenDoesNotExist:
            return true
            
        case .custom, .noWorkspaces:
            return false
     
        }
        
    }
    
}
