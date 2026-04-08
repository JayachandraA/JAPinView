//
//  AccessibilityDemoViewController.swift
//
//  Use-case: Accessibility-first PIN entry demonstrating:
//    • Full VoiceOver support via JAPinAccessibility
//    • Dynamic Type scaling
//    • High-contrast / dark mode aware colours
//    • Respects UIAccessibility.isReduceMotionEnabled
//    • Keyboard navigation (accessibilityActivate)
//    • Live region announcements for state changes
//

import UIKit
import JAPinView

final class AccessibilityDemoViewController: UIViewController {
    
    // MARK: - UI
    
    private let scrollView       = UIScrollView()
    private let contentStack     = UIStackView()
    
    // Demo card
    private let demoCard         = UIView()
    private let headerLabel      = UILabel()
    private let instructionLabel = UILabel()
    private let pinView          = JAPinView()
    private let liveRegionLabel  = UILabel()  // Reads out live updates to VoiceOver
    
    // A11y Settings Monitor Panel
    private let settingsCard     = UIView()
    private let a11yStatusStack  = UIStackView()
    
    // Simulator controls (mirror real device settings for demo)
    private let reduceMotionSwitch    = UISwitch()
    private let highContrastSwitch    = UISwitch()
    private let largeFontSwitch       = UISwitch()
    
    private var useReduceMotion  = UIAccessibility.isReduceMotionEnabled
    private var useHighContrast  = UIAccessibility.isDarkerSystemColorsEnabled
    private var useLargeFont     = UIAccessibility.isBoldTextEnabled
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupPinView()
        registerAccessibilityNotifications()
        refreshA11yStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - View Setup

private extension AccessibilityDemoViewController {
    
    func setupView() {
        title = "Accessibility Demo"
        view.backgroundColor = .systemGroupedBackground
        
        scrollView.alwaysBounceVertical = true
        
        contentStack.axis    = .vertical
        contentStack.spacing = 20
        
        // Demo card
        demoCard.backgroundColor    = .systemBackground
        demoCard.layer.cornerRadius = 16
        demoCard.isAccessibilityElement = false // Let children be navigated
        
        // Header — uses scalable font
        headerLabel.text              = "PIN Entry"
        headerLabel.font              = .preferredFont(forTextStyle: .title2)
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textAlignment     = .center
        headerLabel.accessibilityTraits = .max
        
        // Instructions — scalable, multi-line
        instructionLabel.text         = "Enter your 4-digit PIN. Each cell announces its position. Swipe right with VoiceOver to move between digits."
        instructionLabel.font         = .preferredFont(forTextStyle: .callout)
        instructionLabel.adjustsFontForContentSizeCategory = true
        instructionLabel.textColor    = .secondaryLabel
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        
        // Live region — VoiceOver reads this automatically when it changes
        liveRegionLabel.text              = ""
        liveRegionLabel.font              = .preferredFont(forTextStyle: .footnote)
        liveRegionLabel.adjustsFontForContentSizeCategory = true
        liveRegionLabel.textColor         = .tertiaryLabel
        liveRegionLabel.textAlignment     = .center
        liveRegionLabel.numberOfLines     = 2
        //liveRegionLabel.accessibilityTraits = .updatesFrequently  // Live region
        
        // Settings card
        settingsCard.backgroundColor    = .systemBackground
        settingsCard.layer.cornerRadius = 16
        
        a11yStatusStack.axis    = .vertical
        a11yStatusStack.spacing = 12
        
        // Simulator switches
        [reduceMotionSwitch, highContrastSwitch, largeFontSwitch].forEach {
            $0.onTintColor = .systemGreen
            $0.addAction(UIAction { [weak self] _ in self?.applySimulatedSettings() }, for: .valueChanged)
        }
        reduceMotionSwitch.isOn = useReduceMotion
        highContrastSwitch.isOn = useHighContrast
        largeFontSwitch.isOn    = useLargeFont
    }
    
    func setupPinView() {
        applyCurrentA11yConfiguration()
    }
    
    func applyCurrentA11yConfiguration() {
        // Resolve animation preference
        let animationStyle: JAPinAnimationType = useReduceMotion ? .none : .bounce
        let focusStyle: JAPinAnimationType     = useReduceMotion ? .fade  : .scale
        
        // Resolve contrast-aware colours
        let activeBorder: UIColor = useHighContrast
        ? UIColor { t in t.userInterfaceStyle == .dark ? .white : .black }
        : .systemBlue
        let errorColor: UIColor   = useHighContrast ? .systemRed : UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        
        // Resolve font for Dynamic Type
        let pinFont: UIFont = useLargeFont
        ? UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        : UIFont.preferredFont(forTextStyle: .title1)
        
        var config = JAPinConfiguration(
            pinLength: 4,
            style: .boxed,
            appearance: {
                var a = JAPinAppearance.default
                a.font               = pinFont
                a.activeBorderColor  = activeBorder
                a.errorBorderColor   = errorColor
                a.cursorColor        = activeBorder
                a.cornerRadius       = useHighContrast ? 4 : 10  // Sharper corners for high-contrast
                return a
            }(),
            behavior: JAPinBehavior(
                keyboardType: .numberPad,
                isSecureEntry: false,
                secureSymbol: "•",
                autoFocus: true,
                autoSubmit: true,
                allowsPaste: true,
                enablesAutoFill: true,
                deleteBackwardMovesFocus: true
            ),
            animation: JAPinAnimation(
                focus: focusStyle,
                textEntry: animationStyle,
                error: useReduceMotion ? .none : .shake
            ),
            // Full accessibility configuration
            accessibility: JAPinAccessibility(
                announcesCompletion: true,
                digitLabelFormat: "Position %d of %d"
            )
        )
        
        config.theme.focusedBorderColor = activeBorder
        config.theme.filledBorderColor  = activeBorder
        config.theme.errorBorderColor   = errorColor
        config.theme.cursorColor        = activeBorder
        config.theme.borderWidth        = useHighContrast ? 2.5 : 1.5
        
        pinView.configuration = config
        pinView.delegate      = self
        
        pinView.onComplete = { [weak self] pin in
            self?.handleCompletion(pin)
        }
    }
    
    func handleCompletion(_ pin: String) {
        // Announce to VoiceOver via live region
        let isValid = pin != "0000"
        announceLive(isValid
                     ? "PIN entered successfully."
                     : "Incorrect PIN. Please try again.")
        
        if !isValid {
            pinView.validationFailed()
        } else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func announceLive(_ message: String) {
        liveRegionLabel.text = message
        // Also post explicitly for older iOS / edge cases
        //UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Simulator Settings

private extension AccessibilityDemoViewController {
    
    func applySimulatedSettings() {
        useReduceMotion = reduceMotionSwitch.isOn
        useHighContrast = highContrastSwitch.isOn
        useLargeFont    = largeFontSwitch.isOn
        applyCurrentA11yConfiguration()
        refreshA11yStatus()
        
        announceLive("Settings updated. PIN view reconfigured.")
    }
    
    func refreshA11yStatus() {
        a11yStatusStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Header
        let headerRow = makeStatusRow(icon: "accessibility", title: "System A11y Status", value: nil, color: .label)
        a11yStatusStack.addArrangedSubview(headerRow)
        
        let statuses: [(String, String, Bool)] = [
            ("figure.roll", "VoiceOver",     UIAccessibility.isVoiceOverRunning),
            ("hand.raised",  "Reduce Motion", UIAccessibility.isReduceMotionEnabled),
            ("circle.lefthalf.filled", "High Contrast", UIAccessibility.isDarkerSystemColorsEnabled),
            ("textformat.size", "Bold Text",  UIAccessibility.isBoldTextEnabled),
            ("keyboard",     "Switch Control", UIAccessibility.isSwitchControlRunning),
        ]
        
        for (icon, title, active) in statuses {
            let row = makeStatusRow(
                icon: icon,
                title: title,
                value: active ? "ON" : "off",
                color: active ? .systemGreen : .secondaryLabel
            )
            a11yStatusStack.addArrangedSubview(row)
        }
        
        // Simulated overrides
        let simHeader = UILabel()
        simHeader.text      = "SIMULATED OVERRIDES"
        simHeader.font      = .systemFont(ofSize: 10, weight: .semibold)
        simHeader.textColor = .tertiaryLabel
        a11yStatusStack.setCustomSpacing(12, after: a11yStatusStack.arrangedSubviews.last ?? simHeader)
        a11yStatusStack.addArrangedSubview(simHeader)
    }
    
    func makeStatusRow(icon: String, title: String, value: String?, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis    = .horizontal
        row.spacing = 10
        row.alignment = .center
        
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.setContentHuggingPriority(.required, for: .horizontal)
        img.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        
        row.addArrangedSubview(img)
        row.addArrangedSubview(label)
        
        if let value {
            let val = UILabel()
            val.text          = value
            val.font          = .systemFont(ofSize: 13, weight: .semibold)
            val.textColor     = color
            val.setContentHuggingPriority(.required, for: .horizontal)
            row.addArrangedSubview(val)
        }
        
        return row
    }
}

// MARK: - System Notification Observers

private extension AccessibilityDemoViewController {
    
    func registerAccessibilityNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: NSNotification.Name.UIAccessibilityVoiceOverStatusDidChange,
                       object: nil, queue: .main) { [weak self] _ in self?.refreshA11yStatus() }
        
        nc.addObserver(forName: NSNotification.Name.UIAccessibilityReduceMotionStatusDidChange,
                       object: nil, queue: .main) { [weak self] _ in
            self?.useReduceMotion = UIAccessibility.isReduceMotionEnabled
            self?.reduceMotionSwitch.isOn = UIAccessibility.isReduceMotionEnabled
            self?.applyCurrentA11yConfiguration()
            self?.refreshA11yStatus()
        }
        
        nc.addObserver(forName: NSNotification.Name.UIAccessibilityDarkerSystemColorsStatusDidChange,
                       object: nil, queue: .main) { [weak self] _ in
            self?.useHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
            self?.highContrastSwitch.isOn = UIAccessibility.isDarkerSystemColorsEnabled
            self?.applyCurrentA11yConfiguration()
            self?.refreshA11yStatus()
        }
        
        nc.addObserver(forName: NSNotification.Name.UIAccessibilityBoldTextStatusDidChange,
                       object: nil, queue: .main) { [weak self] _ in
            self?.useLargeFont = UIAccessibility.isBoldTextEnabled
            self?.largeFontSwitch.isOn = UIAccessibility.isBoldTextEnabled
            self?.applyCurrentA11yConfiguration()
            self?.refreshA11yStatus()
        }
    }
}

// MARK: - Layout

private extension AccessibilityDemoViewController {
    
    func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Demo card
        [headerLabel, instructionLabel, pinView, liveRegionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            demoCard.addSubview($0)
        }
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: demoCard.topAnchor, constant: 24),
            headerLabel.leadingAnchor.constraint(equalTo: demoCard.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: demoCard.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: demoCard.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: demoCard.trailingAnchor, constant: -20),
            
            pinView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            pinView.leadingAnchor.constraint(equalTo: demoCard.leadingAnchor, constant: 24),
            pinView.trailingAnchor.constraint(equalTo: demoCard.trailingAnchor, constant: -24),
            pinView.heightAnchor.constraint(equalToConstant: 64),
            
            liveRegionLabel.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 12),
            liveRegionLabel.leadingAnchor.constraint(equalTo: demoCard.leadingAnchor, constant: 20),
            liveRegionLabel.trailingAnchor.constraint(equalTo: demoCard.trailingAnchor, constant: -20),
            liveRegionLabel.bottomAnchor.constraint(equalTo: demoCard.bottomAnchor, constant: -20)
        ])
        
        // Settings card
        let settingsTitle = UILabel()
        settingsTitle.text = "Live A11y Status"
        settingsTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let simTitle = UILabel()
        simTitle.text = "Simulate Overrides"
        simTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let simStack = UIStackView()
        simStack.axis    = .vertical
        simStack.spacing = 12
        
        [("Reduce Motion", reduceMotionSwitch),
         ("High Contrast", highContrastSwitch),
         ("Large / Bold Text", largeFontSwitch)].forEach { (title, sw) in
            let row = makeSimRow(title: title, sw: sw)
            simStack.addArrangedSubview(row)
        }
        
        let innerStack = UIStackView(arrangedSubviews: [
            settingsTitle,
            a11yStatusStack,
            divider(),
            simTitle,
            simStack
        ])
        innerStack.axis    = .vertical
        innerStack.spacing = 12
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        settingsCard.addSubview(innerStack)
        
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: settingsCard.topAnchor, constant: 16),
            innerStack.leadingAnchor.constraint(equalTo: settingsCard.leadingAnchor, constant: 16),
            innerStack.trailingAnchor.constraint(equalTo: settingsCard.trailingAnchor, constant: -16),
            innerStack.bottomAnchor.constraint(equalTo: settingsCard.bottomAnchor, constant: -16)
        ])
        
        contentStack.addArrangedSubview(demoCard)
        contentStack.addArrangedSubview(settingsCard)
    }
    
    func makeSimRow(title: String, sw: UISwitch) -> UIView {
        let row = UIStackView()
        row.axis      = .horizontal
        row.alignment = .center
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14)
        row.addArrangedSubview(label)
        row.addArrangedSubview(sw)
        return row
    }
    
    func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }
}

// MARK: - JAPinViewDelegate

extension AccessibilityDemoViewController: JAPinViewDelegate {
    
    func pinViewDidBeginEditing(_ pinView: JAPinView) {
        announceLive("PIN entry started. Enter 4 digits.")
        liveRegionLabel.text = ""
    }
    
    func pinView(_ pinView: JAPinView, didChangeText text: String) {
        let remaining = 4 - text.count
        if remaining > 0 && !text.isEmpty {
            // Subtle countdown without being too noisy for VoiceOver
            liveRegionLabel.text = "\(text.count) of 4 entered"
        }
    }
    
    func pinView(_ pinView: JAPinView, didComplete text: String) {
        // Handled in onComplete closure
    }
    
    func pinViewDidEndEditing(_ pinView: JAPinView) {
        if !pinView.isComplete {
            announceLive("PIN entry cancelled.")
        }
    }
}
