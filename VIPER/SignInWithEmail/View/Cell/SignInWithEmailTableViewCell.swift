import UIKit

protocol SignInWithEmailCellViewOutput: Loadable {
    func clearTextField()
}

protocol SignInWithEmailTableViewCellDelegate: AnyObject {
    func didTappedGetLinkButtonWith(email: String)
}

private let xOffset = InterfaceUtils.recommendedXOffset

final class SignInWithEmailTableViewCell: UITableViewCell {

    // MARK: - Properties

    weak var delegate: SignInWithEmailTableViewCellDelegate?

    // MARK: - Private properties

    private(set) var loadingIndicator: LoadingIndicator = CometGrapeLoaderView(style: .button)


    // MARK: - Private properties

    private var emailTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString(string: LocalizationConfig.main.signInWithEmailTextFieldPlaceholderText,
                                                             attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        textField.text = UserDefaultsUtils.getValueForKey(.lastSavedMail)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private var separator: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 216 / 255,
                                       green: 216 / 255,
                                       blue: 216 / 255,
                                       alpha: 1)
        return view
    }()

    private var signInWithMailButton: SignInRoundButton = {
        let signInWithMailButton = SignInRoundButton()
        signInWithMailButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithMailButton.setTitle(LocalizationConfig.main.signInWithEmailSendEmailButtonText, for: .normal)

        return signInWithMailButton
    }()

    private var descriptionLabel: UILabel = {
        let textSize: CGFloat = InterfaceUtils.isSmallScreen ? 15 : 18
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hexString: "#666666")
        label.text = LocalizationConfig.main.signInWithEmailSendEmailDescriptionText
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: textSize)

        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        drawSelf()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawSelf()
    }

    // MARK: - Private methods

    private func drawSelf() {

        emailTextField.delegate = self
        backgroundColor = .clear

        signInWithMailButton.addTarget(self, action: #selector(didTappedSignInWithButtonButton), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        signInButton(enabled: emailTextField.text?.isValidEmail() ?? false)

        emailTextField.becomeFirstResponder()

        contentView.addSubview(emailTextField)
        contentView.addSubview(separator)
        contentView.addSubview(signInWithMailButton)
        contentView.addSubview(descriptionLabel)

        signInWithMailButton.addSubview(loadingIndicator.view)
        loadingIndicator.view.autoCenterInSuperview()

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                emailTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),

                separator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
                separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),
                separator.heightAnchor.constraint(equalToConstant: 1),

                signInWithMailButton.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 40),
                signInWithMailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                signInWithMailButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -xOffset),

                descriptionLabel.topAnchor.constraint(equalTo: signInWithMailButton.bottomAnchor, constant: 40),
                descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),
                ])
        } else {
            NSLayoutConstraint.activate([
                emailTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),

                separator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
                separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),
                separator.heightAnchor.constraint(equalToConstant: 1),

                signInWithMailButton.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 40),
                signInWithMailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                signInWithMailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),

                descriptionLabel.topAnchor.constraint(equalTo: signInWithMailButton.bottomAnchor, constant: 40),
                descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -xOffset),
                ])
        }

    }

    @objc private func didTappedSignInWithButtonButton() {
        guard let email = emailTextField.text else { return }
        emailTextField.resignFirstResponder()
        delegate?.didTappedGetLinkButtonWith(email: email)
    }

    @objc private func editingChanged() {
        if let text = emailTextField.text,
            text.isValidEmail() {
            signInButton(enabled: true)
        } else {
            signInButton(enabled: false)
        }
    }

    private func signInButton(enabled: Bool) {
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.signInWithMailButton.alpha = enabled ? 1 : 0.5
        }
        signInWithMailButton.isEnabled = enabled
    }
}

// MARK: - Loadable
extension SignInWithEmailTableViewCell: SignInWithEmailCellViewOutput {

    func clearTextField() {
        emailTextField.text = ""
        signInButton(enabled: false)
    }

    func startAnimating() {
        signInWithMailButton.titleLabel?.layer.opacity = 0
        loadingIndicator.start()
    }

    func stopAnimating() {
        loadingIndicator.stopWithCompletion { [weak self] in
            self?.signInWithMailButton.titleLabel?.layer.opacity = 1
        }
    }

}

// MARK: - UITextFieldDelegate
extension SignInWithEmailTableViewCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
