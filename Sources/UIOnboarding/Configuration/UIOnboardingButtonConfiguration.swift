//
//  UIOnboardingButtonConfiguration.swift
//  UIOnboarding Example
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

public enum UIOnboardingButtonType {
    case regular
    case signIn
}

public struct UIOnboardingButtonConfiguration {
    public var title: String
    public var backgroundColor: UIColor
    public var type: UIOnboardingButtonType

    public init(title: String,
                backgroundColor: UIColor,
                type: UIOnboardingButtonType = .regular) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.type = type
    }
}
