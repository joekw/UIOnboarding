# UIOnboarding

<img src="readme-resources/140222 UIOnboarding Result.png" img>

Configurable animated onboarding screen written programmatically in Swift for UIKit – [inspired](#moodboard) by many Apple-designed user interfaces in iOS – with [Insignia](https://apps.apple.com/ch/app/abzeichen/id1551002238) as an example.

 Designed for iPhone and iPod touch running iOS 13 or higher. Portrait mode only. Supports Dynamic Type, VoiceOver and Reduce Motion.

## Table of Contents

- [Previews](#previews)
    - [Accessibility](#accessibility)
- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Demo Project Download](#demo-project-download)
- [Usage](#usage)
- [Configuration](#configuration-example)
- [Moodboard](#moodboard)
- [License](#license)
- [Links](#links)
- [Icon Usage Rights](#icon-usage-rights)
- [Contributions](#contributions)

## Previews

| Default 6.5" | Default 4" |
|-|-|
| <img src='readme-resources/170222 UIOnboarding Example 6.5".gif' img> | <img src='readme-resources/170222 UIOnboarding Example 4".gif' img width = 240> |

### Accessibility

| Dynamic Type | VoiceOver | Reduce Motion |
|-|-|-|
|<img src="readme-resources/170222 UIOnboarding Example Dynamic Type.gif" img>|<img src="readme-resources/140222 UIOnboarding Example VoiceOver.gif" img>|<img src="readme-resources/170222 UIOnboarding Example Reduce Motion.gif" img>|

## Installation

### Swift Package Manager

To install ```UIOnboarding``` as a package, add ```https://github.com/lascic/UIOnboarding.git``` in the package manager in Xcode (under File/Add Packages...) and select the ```main``` branch.

### Demo Project Download

There is a demo project with and without SPM in the ```Demo``` directory: ```Demo/UIOnboarding Demo``` and ```Demo/UIOnboarding Demo SPM```. You can download them as a .zip file to run it on a physical device or simulator in Xcode. <br>
Before building and running the project, make sure to set it up with your own provisioning profile.

## Usage 

Make sure the view controller you're presenting from is embedded in a ```UINavigationController```. ```OnboardingViewController``` is presented as a full screen view. 

Setting up the
```UIOnboardingViewController```
takes a [```UIOnboardingViewConfiguration```](#configuration)
as the parameter.

``` swift
//In the view controller you're presenting
import UIOnboarding

let onboardingController: UIOnboardingViewController = .init(withConfiguration: .setUp())
onboardingController.delegate = self
navigationController?.present(onboardingController, animated: false)
```

Dismiss the onboarding view with the provided delegate method.

``` swift
extension ViewController: UIOnboardingViewControllerDelegate {
    func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
        onboardingViewController.modalTransitionStyle = .crossDissolve
        onboardingViewController.dismiss(animated: true, completion: nil)
    }
}
```

## Configuration

```UIOnboardingViewConfiguration``` consists of five components.
1. App Icon as ```UIImage```
2. Welcome Title as ```NSMutableAttributedString```
3. Core Features as ```Array<UIOnboardingFeature>```
4. Notice Text as ```UIOnboardingTextViewConfiguration``` (e.g. Privacy Policy, Terms of Service)
5. Continuation Title as ```UIOnboardingButtonConfiguration```

In a helper struct ```UIOnboardingHelper``` we define these components and combine them in an [extension](#extension) of ```UIOnboardingViewConfiguration```.

### Example

``` swift
import UIOnboarding

struct UIOnboardingHelper {
    //App Icon
    static func setUpIcon() -> UIImage {
        return Bundle.main.appIcon ?? .init(named: "onboarding-icon")!
    }

    //Welcome Title
    static func setUpTitle() -> NSMutableAttributedString {
        let welcomeText: NSMutableAttributedString = .init(string: "Welcome to \n",
                                                           attributes: [.foregroundColor: UIColor.label]),
            appNameText: NSMutableAttributedString = .init(string: Bundle.main.displayName ?? "Insignia",
                                                           attributes: [.foregroundColor: UIColor.init(named: "camou")!])
        welcomeText.append(appNameText)
        return welcomeText
    }

    //Core Features
    static func setUpFeatures() -> Array<UIOnboardingFeature> {
        return .init([
            .init(icon: .init(named: "feature-1")!,
                  title: "Search until found",
                  description: "Over a hundred insignia of the Swiss Armed Forces – each redesigned from the ground up."),
            .init(icon: .init(named: "feature-2")!,
                  title: "Enlist prepared",
                  description: "Practice with the app and pass the rank test on the first run."),
            .init(icon: .init(named: "feature-3")!,
                  title: "#teamarmee",
                  description: "Add name tags of your comrades or cadre. Insignia automatically keeps every name tag you create in iCloud.")
        ])
    }

    //Notice Text
    static func setUpNotice() -> UIOnboardingTextViewConfiguration {
        return .init(icon: .init(named: "onboarding-notice-icon")!,
                     text: "Developed and designed for members of the Swiss Armed Forces.",
                     linkTitle: "Learn more...",
                     link: "https://www.lukmanascic.ch/portfolio/insignia",
                     tint: .init(named: "camou"))
    }

    //Continuation Title
    static func setUpButton() -> UIOnboardingButtonConfiguration {
        return .init(title: "Continue",
                     backgroundColor: .init(named: "camou")!)
    }
}
```


### Extension

``` swift
import UIOnboarding

extension UIOnboardingViewConfiguration {
    //UIOnboardingViewController init
    static func setUp() -> UIOnboardingViewConfiguration {
        return .init(appIcon: UIOnboardingHelper.setUpIcon(),
                     welcomeTitle: UIOnboardingHelper.setUpTitle(),
                     features: UIOnboardingHelper.setUpFeatures(),
                     textViewConfiguration: UIOnboardingHelper.setUpNotice(),
                     buttonConfiguration: UIOnboardingHelper.setUpButton())
    }
}
```

## Moodboard

<img src="readme-resources/140222 UIOnboarding Moodboard-1.png" img>
<img src="readme-resources/140222 UIOnboarding Moodboard-2.png" img>

## Links

Swiss Armed Forces Insignia from the App Store: https://apps.apple.com/ch/app/abzeichen/id1551002238.

## License

MIT

## Icon Usage Rights

Some in-app assets provided for this demo project are part of [Insignia](https://apps.apple.com/ch/app/abzeichen/id1551002238).

© 2021 Copyright Lukman Aščić. All rights reserved.

## Contributions

Contributions to UIOnboarding are more than welcome! Please file an issue or submit a pull request.
