//
//  UIOnboardingIcon.swift
//  UIOnboarding Example
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

final class OnboardingIcon: UIImageView {
    init(withConfiguration configuration: UIOnboardingViewConfiguration) {
        super.init(frame: .zero)
        image = configuration.appIcon
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let iconSize: CGFloat = UIScreenType.isiPhoneSE ? 72 : 78
        layer.cornerRadius = iconSize * 0.2237
        
        heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        clipsToBounds = true
    }
}
