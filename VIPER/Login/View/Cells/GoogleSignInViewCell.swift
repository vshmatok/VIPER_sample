import UIKit
import GoogleSignIn

private let xOffset = InterfaceUtils.recommendedXOffset

protocol SignInViewCellDelegate: AnyObject {
    func didTappedSignInWithEmail()
}

final class SignInViewCell: UICollectionViewCell {

    // MARK: - Properties

    weak var delegate: SignInViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawSelf()
    }

    // MARK: - Private methods
    
    private func drawSelf() {
        
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.defaultColor
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.text = LocalizationConfig.main.splashScreenHeader
        titleLabel.numberOfLines = 1
        
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 46)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: xOffset)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: xOffset)
        
        let subTitleLabel = UILabel()
        
        subTitleLabel.textColor = Colors.Alert.textColor
        
        let textSize: CGFloat = InterfaceUtils.isSmallScreen ? 15 : 18
        
        subTitleLabel.font = .systemFont(ofSize: textSize, weight: .bold)
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = LocalizationConfig.main.splashScreenDescription
        
        contentView.addSubview(subTitleLabel)
        
        subTitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 20)
        subTitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: xOffset)
        subTitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: xOffset)

        let signInWithMail = SignInRoundButton()
        signInWithMail.setTitle(LocalizationConfig.main.signInWithEmailButtonText, for: .normal)
        signInWithMail.addTarget(self, action: #selector(didTappedSignInWithButtonButton), for: .touchUpInside)
        contentView.addSubview(signInWithMail)

        signInWithMail.autoPinEdge(.top, to: .bottom, of: subTitleLabel, withOffset: 20)
        signInWithMail.autoPinEdge(toSuperviewEdge: .left, withInset: xOffset)

        let signInButton = GIDSignInButton()
        signInButton.style = .wide
      
        contentView.addSubview(signInButton)
        
        signInButton.autoPinEdge(.top, to: .bottom, of: signInWithMail, withOffset: 20)
        signInButton.autoPinEdge(toSuperviewEdge: .left, withInset: xOffset)
    }

    @objc private func didTappedSignInWithButtonButton() {
        delegate?.didTappedSignInWithEmail()
    }

}
