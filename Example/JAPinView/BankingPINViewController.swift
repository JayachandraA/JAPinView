//
//  BankingPINViewController.swift
//
//  Use-case: Banking-grade 4-digit secure PIN with:
//    • Masked entry (• symbol)
//    • Two-step create → confirm flow
//    • Attempt limiting with lockout
//    • LocalAuthentication biometric gate before PIN reveal
//    • Underlined style matching typical banking UI
//

import UIKit
import LocalAuthentication
import JAPinView

final class BankingPINViewController: UIViewController {

    // MARK: - State

    private enum Step {
        case create
        case confirm(firstPIN: String)
        case verify
    }

    private var step: Step = .create {
        didSet { transitionToCurrentStep() }
    }

    private var savedPIN: String? // In production: store in Keychain
    private var failedAttempts = 0
    private let maxAttempts    = 3
    private var isLockedOut    = false

    // MARK: - UI

    private let containerStack = UIStackView()
    private let lockIconView   = UIImageView()
    private let titleLabel     = UILabel()
    private let subtitleLabel  = UILabel()
    private let pinView        = JAPinView()
    private let attemptsLabel  = UILabel()
    private let actionButton   = UIButton(type: .system)
    private let biometricButton = UIButton(type: .system)
    private let progressView   = UIProgressView(progressViewStyle: .bar)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupPinView()
        transitionToCurrentStep()
    }
}

// MARK: - View Setup

private extension BankingPINViewController {

    func setupView() {
        title = "Secure PIN"
        view.backgroundColor = UIColor(
            red: 0.04, green: 0.06, blue: 0.14, alpha: 1
        ).withAlphaComponent(0.5)

        // Lock icon
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        lockIconView.image = UIImage(systemName: "lock.shield.fill", withConfiguration: symbolConfig)
        lockIconView.tintColor = .systemYellow
        lockIconView.contentMode = .scaleAspectFit

        // Stack
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.spacing = 16

        // Labels
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2

        attemptsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        attemptsLabel.textColor = .systemOrange
        attemptsLabel.textAlignment = .center
        attemptsLabel.alpha = 0

        // Progress bar (dots-style mock)
        progressView.progressTintColor = .systemYellow
        progressView.trackTintColor    = UIColor.white.withAlphaComponent(0.15)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.progress = 0

        // Action button
        var cfg = UIButton.Configuration.filled()
        cfg.cornerStyle = .capsule
        cfg.baseBackgroundColor = .systemYellow
        cfg.baseForegroundColor  = .black
        cfg.title = "Continue"
        cfg.buttonSize = .large
        actionButton.configuration = cfg
        actionButton.isHidden = true
        actionButton.addAction(UIAction { [weak self] _ in self?.handleActionButton() }, for: .touchUpInside)

        // Biometric button
        biometricButton.setImage(
            UIImage(systemName: biometricIconName()),
            for: .normal
        )
        biometricButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        biometricButton.isHidden = true
        biometricButton.addAction(UIAction { [weak self] _ in self?.authenticateWithBiometrics() }, for: .touchUpInside)
    }

    func setupLayout() {
        [containerStack, biometricButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [lockIconView, titleLabel, subtitleLabel, pinView,
         progressView, attemptsLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerStack.addArrangedSubview($0)
        }

        containerStack.setCustomSpacing(24, after: subtitleLabel)
        containerStack.setCustomSpacing(12, after: pinView)
        containerStack.setCustomSpacing(24, after: attemptsLabel)

        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            lockIconView.heightAnchor.constraint(equalToConstant: 56),
            pinView.heightAnchor.constraint(equalToConstant: 60),
            pinView.widthAnchor.constraint(equalTo: containerStack.widthAnchor),
            progressView.widthAnchor.constraint(equalTo: containerStack.widthAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            actionButton.widthAnchor.constraint(equalTo: containerStack.widthAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 52),

            biometricButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            biometricButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            biometricButton.widthAnchor.constraint(equalToConstant: 56),
            biometricButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func setupPinView() {
        var config = JAPinConfiguration(
            pinLength: 4,
            style: .underlined,
            appearance: {
                var a = JAPinAppearance.default
                a.font            = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
                a.textColor       = .white
                a.spacing         = 24
                a.cursorColor     = .systemYellow
                a.cursorWidth     = 2.5
                return a
            }(),
            behavior: JAPinBehavior(
                keyboardType: .numberPad,
                isSecureEntry: true,
                secureSymbol: "●",
                autoFocus: true,
                autoSubmit: true,
                allowsPaste: false,           // Never allow paste for banking PINs
                enablesAutoFill: false,       // No SMS autofill for PIN
                deleteBackwardMovesFocus: true
            ),
            animation: JAPinAnimation(
                focus: .scale,
                textEntry: .fade,
                error: .shake
            ),
            accessibility: JAPinAccessibility(
                announcesCompletion: false,   // Don't announce PIN completion aloud
                digitLabelFormat: "PIN digit %d"
            )
        )

        // Dark theme to match banking UI
        config.theme.emptyBorderColor   = UIColor.white.withAlphaComponent(0.25)
        config.theme.focusedBorderColor = .systemYellow
        config.theme.filledBorderColor  = UIColor.white.withAlphaComponent(0.8)
        config.theme.errorBorderColor   = .systemRed
        config.theme.cursorColor        = .systemYellow

        pinView.configuration = config
        pinView.delegate      = self

        pinView.onChange = { [weak self] pin in
            let fraction = Float(pin.count) / 4.0
            UIView.animate(withDuration: 0.1) {
                self?.progressView.setProgress(fraction, animated: true)
            }
        }
    }
}

// MARK: - Step Transitions

private extension BankingPINViewController {

    func transitionToCurrentStep() {
        pinView.clear()
        attemptsLabel.alpha = 0
        actionButton.isHidden = true

        UIView.transition(with: containerStack, duration: 0.25,
                          options: .transitionCrossDissolve) {
            switch self.step {
            case .create:
                self.titleLabel.text    = "Create PIN"
                self.subtitleLabel.text = "Choose a 4-digit PIN\nto secure your account"
                self.biometricButton.isHidden = true

            case .confirm:
                self.titleLabel.text    = "Confirm PIN"
                self.subtitleLabel.text = "Re-enter your PIN\nto confirm"
                self.biometricButton.isHidden = true

            case .verify:
                self.titleLabel.text    = "Enter PIN"
                self.subtitleLabel.text = "Use your PIN to access\nyour account"
                self.biometricButton.isHidden = self.savedPIN == nil
                if self.savedPIN != nil { self.authenticateWithBiometrics() }
            }
        }
    }
}

// MARK: - PIN Logic

private extension BankingPINViewController {

    func handlePINComplete(_ pin: String) {
        guard !isLockedOut else { return }

        switch step {
        case .create:
            // Move to confirm step
            step = .confirm(firstPIN: pin)

        case .confirm(let firstPIN):
            if pin == firstPIN {
                savedPIN = pin
                showToast("PIN created successfully ✓", color: .systemGreen)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.step = .verify
                }
            } else {
                pinView.validationFailed()
                showToast("PINs don't match. Try again.", color: .systemOrange)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.step = .create
                }
            }

        case .verify:
            verifyPIN(pin)
        }
    }

    func verifyPIN(_ pin: String) {
        pinView.setLoading(true)

        // Simulate async verification (Keychain / server check)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            self.pinView.setLoading(false)

            if pin == self.savedPIN {
                self.failedAttempts = 0
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.showToast("Access granted ✓", color: .systemGreen)
            } else {
                self.failedAttempts += 1
                self.pinView.validationFailed()
                self.handleFailedAttempt()
            }
        }
    }

    func handleFailedAttempt() {
        let remaining = maxAttempts - failedAttempts
        if remaining <= 0 {
            lockOut()
        } else {
            UIView.animate(withDuration: 0.2) {
                self.attemptsLabel.alpha = 1
            }
            attemptsLabel.text = remaining == 1
                ? "⚠️ Last attempt before lockout!"
                : "\(remaining) attempts remaining"
        }
    }

    func lockOut() {
        isLockedOut = true
        pinView.isDisabled = true
        attemptsLabel.text  = "🔒 Account locked. Contact support."
        UIView.animate(withDuration: 0.2) { self.attemptsLabel.alpha = 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func handleActionButton() {
        step = .create
    }
}

// MARK: - Biometrics

private extension BankingPINViewController {

    func biometricIconName() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }

    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access your account"
        ) { [weak self] success, _ in
            DispatchQueue.main.async {
                if success {
                    self?.showToast("Biometric access granted ✓", color: .systemGreen)
                }
            }
        }
    }
}

// MARK: - Toast Helper

private extension BankingPINViewController {

    func showToast(_ message: String, color: UIColor) {
        let toast = UILabel()
        toast.text            = message
        toast.font            = .systemFont(ofSize: 13, weight: .medium)
        toast.textColor       = .black
        toast.backgroundColor = color
        toast.textAlignment   = .center
        toast.layer.cornerRadius = 12
        toast.clipsToBounds   = true
        toast.alpha           = 0
        toast.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])
        toast.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { toast.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - JAPinViewDelegate

extension BankingPINViewController: JAPinViewDelegate {

    func pinViewDidBeginEditing(_ pinView: JAPinView) {
        progressView.setProgress(0, animated: false)
    }

    func pinView(_ pinView: JAPinView, didChangeText text: String) {
        // Progress bar updated via onChange closure in setupPinView
    }

    func pinView(_ pinView: JAPinView, didComplete text: String) {
        handlePINComplete(text)
    }

    func pinViewDidEndEditing(_ pinView: JAPinView) {}
}
