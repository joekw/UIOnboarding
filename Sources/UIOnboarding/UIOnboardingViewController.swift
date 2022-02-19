//
//  UIOnboardingViewController.swift
//  UIOnboarding Example
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

public final class UIOnboardingViewController: UIViewController {
    private var onboardingScrollView: UIScrollView!
    private var onboardingStackView: UIOnboardingStack!
    private var topOverlayView: UIOnboardingOverlay!
    private var bottomOverlayView: UIOnboardingOverlay!
    private var continueButton: UIOnboardingButton!
    private var onboardingTextView: UIOnboardingTextView!

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
    
    public init(withConfiguration configuration: UIOnboardingViewConfiguration, device: UIDevice = .current) {
        self.configuration = configuration
        self.device = device
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("UIOnboardingViewController: deinit {}")
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureScrollView()
        setUpTopOverlay()
    }
        
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingAnimation()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
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
        onboardingScrollView.backgroundColor = .systemGroupedBackground
        onboardingScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(onboardingScrollView)
        pin(onboardingScrollView, toEdgesOf: view)
        
        setUpOnboardingStackView()
        setUpBottomOverlay()
    }
    
    func setUpOnboardingStackView() {
        onboardingStackView = .init(withConfiguration: configuration)
        onboardingScrollView.addSubview(onboardingStackView)
        
        onboardingStackView.topAnchor.constraint(equalTo: onboardingScrollView.topAnchor).isActive = true
        onboardingStackView.bottomAnchor.constraint(equalTo: onboardingScrollView.bottomAnchor).isActive = true
        onboardingStackView.leadingAnchor.constraint(equalTo: onboardingScrollView.leadingAnchor, constant: UIScreenType.setUpPadding()).isActive = true
        onboardingStackView.trailingAnchor.constraint(equalTo: onboardingScrollView.trailingAnchor, constant: UIScreenType.setUpPadding()).isActive = true
    }

    func setUpTopOverlay() {
        topOverlayView = .init(frame: .zero)
        view.addSubview(topOverlayView)
        
        topOverlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topOverlayView.heightAnchor.constraint(equalToConstant: getStatusBarHeight()).isActive = true
    }

    func setUpBottomOverlay() {
        bottomOverlayView = .init(frame: .zero)
        view.addSubview(bottomOverlayView)
        
        bottomOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        setUpOnboardingButton()
        setUpOnboardingTextView()
    }

    func setUpOnboardingButton() {
        continueButton = .init(withConfiguration: configuration.buttonConfiguration)
        continueButton.delegate = self
        bottomOverlayView.addSubview(continueButton)
        
        continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        continueButton.leadingAnchor.constraint(equalTo: bottomOverlayView.leadingAnchor, constant: UIScreenType.setUpButtonPadding()).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: bottomOverlayView.trailingAnchor, constant: -UIScreenType.setUpButtonPadding()).isActive = true
        continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreenType.isiPhoneSE ? 46 : 52).isActive = true
    }
    
    func setUpOnboardingTextView() {
        guard let textConfiguration = configuration.textViewConfiguration else {
            bottomOverlayView.topAnchor.constraint(equalTo: continueButton.topAnchor, constant: -40).isActive = true
            return
        }

        onboardingTextView = .init(withConfiguration: textConfiguration)
        bottomOverlayView.addSubview(onboardingTextView)
        
        onboardingTextView.bottomAnchor.constraint(equalTo: continueButton.topAnchor).isActive = true
        onboardingTextView.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor).isActive = true
        onboardingTextView.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor).isActive = true
        onboardingTextView.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: 16).isActive = true
    }
    
    func startOnboardingAnimation() {
        UIView.animate(withDuration: UIAccessibility.isReduceMotionEnabled ? 0.3 : 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
            self.onboardingStackView.transform = .identity
            self.onboardingStackView.alpha = 1
        } completion: { (_) in
            self.onboardingStackView.animate {
                self.bottomOverlayView.alpha = 1
                self.onboardingScrollView.isScrollEnabled = true
            }
        }
    }
    
    func updateUI() {
        onboardingScrollView.contentInset = .init(top: UIScreenType.setUpTopSpacing(),
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
        
        continueButton.sizeToFit()
    }
}

extension UIOnboardingViewController: UIOnboardingButtonDelegate {
    func didPressContinueButton() {
        delegate?.didFinishOnboarding(onboardingViewController: self)
    }
}
