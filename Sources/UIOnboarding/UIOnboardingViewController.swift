//
//  UIOnboardingViewController.swift
//  UIOnboarding Example
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit
import Purchases
import SafariServices
import AuthenticationServices
import CryptoKit

public final class UIOnboardingViewController: UIViewController {
    private var onboardingScrollView: UIScrollView!
    private var onboardingStackView: UIOnboardingStack!
    private var topOverlayView: UIOnboardingOverlay!
    private var bottomOverlayView: UIOnboardingOverlay!
    private var onboardingTextView: UIOnboardingTextView!
    private var onboardingButtonStackView: UIStackView!
    private var packages: [Purchases.Package]?
    fileprivate var currentNonce: String?

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var animationShown = false

    private lazy var restorePurchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restore", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.App.sectionTitleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.addTarget(self, action: #selector(restoreTap(sender:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms of Use", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.App.sectionTitleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.addTarget(self, action: #selector(termsTap), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.App.sectionTitleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.addTarget(self, action: #selector(privacyTap), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    private lazy var statusBarHeight: CGFloat = getStatusBarHeight()

    private var enoughSpaceToShowFullList: Bool {
        let onboardingStackHeight: CGFloat = onboardingStackView.frame.height
        let availableSpace: CGFloat = (view.frame.height - bottomOverlayView.frame.height - (device.hasNotch ? 120 : 70))
        return onboardingStackHeight > availableSpace
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private let configuration: UIOnboardingViewConfiguration
    private let device: UIDevice
    public weak var delegate: UIOnboardingViewControllerDelegate?
    public weak var plusDelegate: PlusDelegate?
    
    public init(withConfiguration configuration: UIOnboardingViewConfiguration, device: UIDevice = .current, presentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.configuration = configuration
        self.device = device
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = presentationStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("UIOnboardingViewController: deinit {}")
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !animationShown {
            configureScrollView()
            setUpTopOverlay()
        }
        if modalPresentationStyle == .pageSheet {
            self.navigationItem.setLeftBarButton(UIBarButtonItem.menuButton(self, action: #selector(close), image: UIImage(systemName: "xmark"), text: nil, style: .tintedCircle), animated: true)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
        
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animationShown {
            startOnboardingAnimation()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }

    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIOnboardingViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var viewOverlapsWithOverlay: Bool {
            return scrollView.contentOffset.y >= -(self.statusBarHeight / 1.5)
        }
        UIView.animate(withDuration: 0.21) {
            self.topOverlayView.alpha = viewOverlapsWithOverlay ? 1 : 0
        }
    }
}

extension UIOnboardingViewController {
    func configureScrollView() {
        onboardingScrollView = .init(frame: .zero)
        onboardingScrollView.delegate = self
        
        onboardingScrollView.isScrollEnabled = false
        onboardingScrollView.showsHorizontalScrollIndicator = false
        onboardingScrollView.backgroundColor = UIColor.App.backgroundColor
        onboardingScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(onboardingScrollView)
        onboardingScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        onboardingScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        onboardingScrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        onboardingScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        onboardingScrollView.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: onboardingScrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: onboardingScrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: onboardingScrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: onboardingScrollView.bottomAnchor).isActive = true

        setUpOnboardingStackView()
        setUpBottomOverlay()
    }
    
    func setUpOnboardingStackView() {
        onboardingStackView = .init(withConfiguration: configuration)
        contentView.addSubview(onboardingStackView)
        
        onboardingStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        onboardingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        onboardingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIScreenType.setUpPadding()).isActive = true
        onboardingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIScreenType.setUpPadding()).isActive = true
    }

    func setUpTopOverlay() {
        topOverlayView = .init(frame: .zero)
        view.addSubview(topOverlayView)
        
        topOverlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        let height = modalPresentationStyle == .fullScreen ? getStatusBarHeight() : 0
        topOverlayView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func setUpBottomOverlay() {
        bottomOverlayView = .init(frame: .zero)
        view.addSubview(bottomOverlayView)
        
        bottomOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        setUpOnboardingButtons()
        setUpOnboardingTextView()
    }

    func setUpOnboardingButtons() {
        onboardingButtonStackView = .init()
        onboardingButtonStackView.axis = .vertical
        onboardingButtonStackView.distribution = .equalSpacing
        onboardingButtonStackView.spacing = 10
        onboardingButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomOverlayView.addSubview(onboardingButtonStackView)

        if configuration.showLinks {
            let linksStackView = UIStackView(arrangedSubviews: [termsButton, privacyButton, restorePurchaseButton])
            linksStackView.axis = .horizontal
            linksStackView.distribution = .fillEqually
            linksStackView.spacing = 5
            linksStackView.translatesAutoresizingMaskIntoConstraints = false
            bottomOverlayView.addSubview(linksStackView)

            linksStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            linksStackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
            linksStackView.leadingAnchor.constraint(equalTo: bottomOverlayView.leadingAnchor, constant: UIScreenType.setUpButtonPadding()).isActive = true
            linksStackView.trailingAnchor.constraint(equalTo: bottomOverlayView.trailingAnchor, constant: -UIScreenType.setUpButtonPadding()).isActive = true

            onboardingButtonStackView.bottomAnchor.constraint(equalTo: linksStackView.topAnchor, constant: -10).isActive = true

            setupPurchases()
        } else {
            onboardingButtonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true

            for buttonConfig in configuration.buttonConfiguration {
                if buttonConfig.type == .regular {
                    let button = SymbolButton(title: buttonConfig.title)
                    button.addTarget(self, action: #selector(didPressContinueButton), for: .touchUpInside)
                    button.layer.cornerRadius = 5
                    onboardingButtonStackView.addArrangedSubview(button)
                    button.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreenType.isiPhoneSE ? 46 : 52.catalystScaled).isActive = true
                } else if buttonConfig.type == .signIn {
                    let button = ASAuthorizationAppleIDButton(type: .continue, style: .white)
                    button.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
                    onboardingButtonStackView.addArrangedSubview(button)
                    button.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreenType.isiPhoneSE ? 46 : 52.catalystScaled).isActive = true
                }
            }
        }

        onboardingButtonStackView.leadingAnchor.constraint(equalTo: bottomOverlayView.leadingAnchor, constant: UIScreenType.setUpButtonPadding()).isActive = true
        onboardingButtonStackView.trailingAnchor.constraint(equalTo: bottomOverlayView.trailingAnchor, constant: -UIScreenType.setUpButtonPadding()).isActive = true
    }
    
    func setUpOnboardingTextView() {
        guard let textConfiguration = configuration.textViewConfiguration else {
            bottomOverlayView.topAnchor.constraint(equalTo: onboardingButtonStackView.topAnchor, constant: -40).isActive = true
            return
        }

        onboardingTextView = .init(withConfiguration: textConfiguration)
        bottomOverlayView.addSubview(onboardingTextView)
        
        onboardingTextView.bottomAnchor.constraint(equalTo: onboardingButtonStackView.topAnchor).isActive = true
        onboardingTextView.leadingAnchor.constraint(equalTo: onboardingButtonStackView.leadingAnchor).isActive = true
        onboardingTextView.trailingAnchor.constraint(equalTo: onboardingButtonStackView.trailingAnchor).isActive = true
        onboardingTextView.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: 16).isActive = true
    }
    
    func startOnboardingAnimation() {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
            self.onboardingStackView.transform = .identity
            self.onboardingStackView.alpha = 1
        } completion: { (_) in
            self.onboardingStackView.animate {
                self.bottomOverlayView.alpha = 1
                self.onboardingScrollView.isScrollEnabled = true
                self.animationShown = true
            }
        }
    }
    
    func updateUI() {
        onboardingScrollView.contentInset = .init(top: UIScreenType.setUpTopSpacing(presentationStyle: modalPresentationStyle),
                                                  left: 0,
                                                  bottom: bottomOverlayView.frame.height + 16,
                                                  right: 0)
        onboardingScrollView.scrollIndicatorInsets = .init(top: 0,
                                                           left: 0,
                                                           bottom: bottomOverlayView.frame.height,
                                                           right: 0)
        bottomOverlayView.subviews.first?.alpha = enoughSpaceToShowFullList ? 1 : 0
        
        onboardingScrollView.isScrollEnabled = enoughSpaceToShowFullList
        onboardingScrollView.showsVerticalScrollIndicator = enoughSpaceToShowFullList
    }

    private func setupPurchases() {
        Purchases.shared.offerings { (offerings, error) in
            Purchases.shared.purchaserInfo { (purchaserInfo, error) in
                if let packages = offerings?.current?.availablePackages {
                    self.packages = packages
                    self.addPurchaseButtons(for: packages)
                }
            }
        }
    }

    private func addPurchaseButtons(for packages: [Purchases.Package]) {
        var monthlyPackage: Purchases.Package?
        var annualPackage: Purchases.Package?
        var annualButton: SymbolButton?

        for (index, package) in packages.enumerated() {
            let button = SymbolButton()
            button.addTarget(self, action: #selector(purchaseTapped(sender:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            switch package.packageType {
            case .annual:
                annualPackage = package
                button.title = "\(package.localizedPriceString)"
                button.subtitle = "Annual"
                annualButton = button
            case .monthly:
                monthlyPackage = package
                button.title = "\(package.localizedPriceString)"
                button.subtitle = "Monthly"
            case .lifetime:
                button.title = "\(package.localizedPriceString)"
                button.subtitle = "One-time"
            default:
                return
            }
            button.tag = index
            onboardingButtonStackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true

            if let monthlyPrice = monthlyPackage?.product.price, let annual = annualPackage?.product.price {
                let monthly = monthlyPrice.multiplying(by: 12)
                let offer = (annual as Decimal) / (monthly as Decimal)
                annualButton?.offer = offer
            }
        }
    }
}

extension UIOnboardingViewController: UIOnboardingButtonDelegate {
    @objc func didPressContinueButton() {
        delegate?.didFinishOnboarding(onboardingViewController: self)
    }
}

extension UIOnboardingViewController {
    @objc func purchaseTapped(sender: SubscribeButton) {
        guard let package = packages?[sender.tag] else { return }
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            if let err = error as NSError? {
                self.showError(err)
            } else {
                self.plusDelegate?.plusPurchased()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func restoreTap(sender: UIButton) {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            if let err = error as NSError? {
                self.showError(err)
            }
        }
    }

    private func showError(_ error: NSError) {
        switch Purchases.ErrorCode(_nsError: error).code {
        case .purchaseNotAllowedError:
            self.showAlert("Purchases not allowed on this device.")
        case .purchaseInvalidError:
            self.showAlert("Purchase invalid, check payment source.")
        case .networkError, .storeProblemError:
            self.showAlert("Network error, please check your connection.")
        case .unexpectedBackendResponseError, .unknownBackendError, .unknownError:
            self.showAlert("Unknown server error, please try again.")
        default:
            break
        }
    }

    @objc private func termsTap() {
        if let url = URL(string: "https://gametrack.app/terms/") {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }

    @objc private func privacyTap() {
        if let url = URL(string: "https://gametrack.app/privacypolicy/") {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }

    private func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Purchase Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) -> Void in
            print("ok button tapped")
        })

        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIOnboardingViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    @objc private func handleAppleIdRequest() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            AccountManager.createGameTrackAccount(token: idTokenString, nonce: nonce, name: appleIDCredential.fullName, delegate: self)
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }

        AccountManager.handleError(error, delegate: self)
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension UIOnboardingViewController: AccountManagerDelegate {
    func presentError(_ controller: UIAlertController) {
        self.present(controller, animated: true)
    }

    func signUpCompleted() {
        let usernamePicker = UsernamePickerController()
        navigationController?.pushViewController(usernamePicker, animated: true)
    }

    func signInCompleted() {
        self.dismiss(animated: true)
    }
}
