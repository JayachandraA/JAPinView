//
//  BasicOTPViewController.swift
//
//  Use-case: Simple 6-digit OTP that auto-fills from SMS and shows
//  inline success / failure feedback without any network call.
//

import UIKit
import JAPinView

final class BasicOTPViewController: UIViewController {

    // MARK: - UI

    private let cardView       = UIView()
    private let iconImageView  = UIImageView()
    private let titleLabel     = UILabel()
    private let subtitleLabel  = UILabel()
    private let pinView        = JAPinView()
    private let statusLabel    = UILabel()
    private let resendButton   = UIButton(type: .system)
    private var resendTimer: Timer?
    private var resendCountdown = 30

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupPinView()
        startResendTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resendTimer?.invalidate()
    }
}

// MARK: - View Setup

private extension BasicOTPViewController {

    func setupView() {
        title = "Verify OTP"
        view.backgroundColor = .systemGroupedBackground
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            systemItem: .cancel,
//            primaryAction: UIAction { [weak self] _ in
//                self?.dismiss(animated: true)
//            }
//        )

        // Card
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor  = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius  = 16
        cardView.layer.shadowOffset  = CGSize(width: 0, height: 4)

        // Icon
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        iconImageView.image = UIImage(systemName: "message.badge.filled.fill", withConfiguration: config)
        iconImageView.tintColor = .systemIndigo
        iconImageView.contentMode = .scaleAspectFit

        // Title
        titleLabel.text = "Enter Verification Code"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center

        // Subtitle
        subtitleLabel.text = "We sent a 6-digit code to\n+91 98765 ••••• 10"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2

        // Status
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.alpha = 0

        // Resend
        resendButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        resendButton.addAction(UIAction { [weak self] _ in self?.handleResend() }, for: .touchUpInside)
    }

    func setupLayout() {
        [cardView, iconImageView, titleLabel, subtitleLabel, pinView,
         statusLabel, resendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(cardView)
        [iconImageView, titleLabel, subtitleLabel, pinView,
         statusLabel, resendButton].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            iconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 56),
            iconImageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            pinView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            pinView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            pinView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            pinView.heightAnchor.constraint(equalToConstant: 56),

            statusLabel.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            resendButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            resendButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            resendButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),
            resendButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func setupPinView() {
        var config = JAPinConfiguration.default
        config.pinLength  = 6
        config.style      = .boxed

        // Theme: indigo brand colors
        config.theme.focusedBorderColor = .systemIndigo
        config.theme.filledBorderColor  = .systemIndigo
        config.theme.cursorColor        = .systemIndigo

        // Behavior: enable SMS auto-fill
        config.behavior.enablesAutoFill = true
        config.behavior.allowsPaste     = true
        config.behavior.isSecureEntry   = false

        // Animation: scale on focus, bounce on entry
        config.animation = JAPinAnimation(
            focus: .scale,
            textEntry: .bounce,
            error: .shake
        )

        // Accessibility: custom format
        config.accessibility = JAPinAccessibility(
            announcesCompletion: true,
            digitLabelFormat: "OTP digit %d of %d"
        )

        pinView.configuration = config
        pinView.delegate = self

        // Closure-based completion handler
        pinView.onComplete = { [weak self] otp in
            self?.verifyOTP(otp)
        }
    }
}

// MARK: - OTP Logic

private extension BasicOTPViewController {

    func verifyOTP(_ otp: String) {
        pinView.setLoading(true)
        setStatus(nil)

        // Simulate a 1.2 s network round-trip
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            self.pinView.setLoading(false)

            // Accept "123456" as the correct OTP for demo purposes
            if otp == "123456" {
                self.handleSuccess()
            } else {
                self.handleFailure()
            }
        }
    }

    func handleSuccess() {
        setStatus("✓  Verified successfully", color: .systemGreen)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    func handleFailure() {
        pinView.validationFailed()
        setStatus("✗  Incorrect code. Try again.", color: .systemRed)
    }

    func setStatus(_ message: String?, color: UIColor = .label) {
        statusLabel.text      = message
        statusLabel.textColor = color
        UIView.animate(withDuration: 0.2) {
            self.statusLabel.alpha = message == nil ? 0 : 1
        }
    }
}

// MARK: - Resend Timer

private extension BasicOTPViewController {

    func startResendTimer() {
        resendCountdown = 30
        updateResendButton()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.resendCountdown -= 1
            self.updateResendButton()
            if self.resendCountdown <= 0 { self.resendTimer?.invalidate() }
        }
    }

    func updateResendButton() {
        if resendCountdown > 0 {
            resendButton.setTitle("Resend code in \(resendCountdown)s", for: .normal)
            resendButton.isEnabled = false
            resendButton.tintColor = .tertiaryLabel
        } else {
            resendButton.setTitle("Resend code", for: .normal)
            resendButton.isEnabled = true
            resendButton.tintColor = .systemIndigo
        }
    }

    func handleResend() {
        pinView.clear()
        setStatus("Code resent!", color: .systemIndigo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.setStatus(nil)
        }
        startResendTimer()
    }
}

// MARK: - JAPinViewDelegate

extension BasicOTPViewController: JAPinViewDelegate {

    func pinViewDidBeginEditing(_ pinView: JAPinView) {
        setStatus(nil)
    }

    func pinView(_ pinView: JAPinView, didChangeText text: String) {
        // Progress hint: light feedback on every digit entry
    }

    func pinView(_ pinView: JAPinView, didComplete text: String) {
        // onComplete closure handles this; delegate kept for logging / analytics
        print("[BasicOTP] didComplete:", text)
    }

    func pinViewDidEndEditing(_ pinView: JAPinView) {
        print("[BasicOTP] didEndEditing")
    }
}
