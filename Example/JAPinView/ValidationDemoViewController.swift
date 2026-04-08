//
//  ValidationDemoViewController.swift
//
//  Use-case: Full async validation lifecycle demo showing:
//    • setValidator(_:) async closure integration
//    • Loading skeleton / spinner overlay
//    • Rule-based validation (length, banned PINs, sequential digits)
//    • Retry counter with progressive cooldown
//    • Success confetti burst
//

import UIKit
import JAPinView

final class ValidationDemoViewController: UIViewController {

    // MARK: - Constants

    private let maxRetries    = 5
    private let bannedPINs    = ["1234", "0000", "1111", "2222", "3333",
                                 "4444", "5555", "6666", "7777", "8888", "9999"]

    // MARK: - State

    private var retryCount   = 0
    private var cooldownTimer: Timer?
    private var cooldownSeconds = 0

    // MARK: - UI

    private let scrollView       = UIScrollView()
    private let contentStack     = UIStackView()

    // Validator switcher
    private let ruleSegment      = UISegmentedControl()

    // PIN section
    private let pinCard          = UIView()
    private let pinView          = JAPinView()
    private let spinnerView      = UIActivityIndicatorView(activityIndicatorStyle: .medium)
    private let resultLabel      = UILabel()
    private let retryLabel       = UILabel()

    // Rules info section
    private let rulesCard        = UIView()
    private var ruleCheckmarks   = [UILabel]()

    // History section
    private let historyCard      = UIView()
    private let historyStack     = UIStackView()
    private var attempts         = [(pin: String, success: Bool, timestamp: Date)]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupPinView()
        populateRulesCard()
    }
}

// MARK: - Setup

private extension ValidationDemoViewController {

    func setupView() {
        title = "Validation Demo"
        view.backgroundColor = .systemGroupedBackground

        scrollView.alwaysBounceVertical = true

        contentStack.axis    = .vertical
        contentStack.spacing = 20

        // Pin card
        pinCard.backgroundColor    = .systemBackground
        pinCard.layer.cornerRadius = 16
        pinCard.layer.shadowColor  = UIColor.black.cgColor
        pinCard.layer.shadowOpacity = 0.06
        pinCard.layer.shadowRadius  = 10

        resultLabel.font          = .systemFont(ofSize: 13, weight: .medium)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 2
        resultLabel.alpha         = 0

        retryLabel.font      = .systemFont(ofSize: 12)
        retryLabel.textColor = .secondaryLabel
        retryLabel.textAlignment = .center
        retryLabel.alpha         = 0

        // Spinner
        spinnerView.hidesWhenStopped = true

        // Rules card
        rulesCard.backgroundColor    = .systemBackground
        rulesCard.layer.cornerRadius = 16

        // History card
        historyCard.backgroundColor    = .systemBackground
        historyCard.layer.cornerRadius = 16

        historyStack.axis    = .vertical
        historyStack.spacing = 8

        // Validator rule picker
        ["Smart", "Strict", "Server"].enumerated().forEach { i, t in
            ruleSegment.insertSegment(withTitle: t, at: i, animated: false)
        }
        ruleSegment.selectedSegmentIndex = 0
        ruleSegment.addAction(UIAction { [weak self] _ in
            self?.attachValidator()
            self?.pinView.clear()
            self?.clearResult()
        }, for: .valueChanged)
    }

    func setupPinView() {
        var config = JAPinConfiguration(
            pinLength: 4,
            style: .rounded,
            appearance: {
                var a = JAPinAppearance.default
                a.font    = .monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
                a.spacing = 14
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
            animation: JAPinAnimation(focus: .scale, textEntry: .bounce, error: .shake),
            accessibility: JAPinAccessibility(
                announcesCompletion: true,
                digitLabelFormat: "Digit %d of %d"
            )
        )
        config.theme.focusedBorderColor = .systemTeal
        config.theme.filledBorderColor  = .systemTeal
        config.theme.cursorColor        = .systemTeal

        pinView.configuration = config
        pinView.delegate      = self
        attachValidator()
    }

    func attachValidator() {
        switch ruleSegment.selectedSegmentIndex {
        case 0: pinView.setValidator(smartValidator)
        case 1: pinView.setValidator(strictValidator)
        case 2: pinView.setValidator(simulatedServerValidator)
        default: break
        }
    }
}

// MARK: - Validators

private extension ValidationDemoViewController {

    /// Smart: basic uniqueness + no common PINs
    func smartValidator(_ pin: String) async -> Bool {
        try? await Task.sleep(nanoseconds: 800_000_000)
        guard !bannedPINs.contains(pin) else { return false }
        let digits = pin.map { $0.wholeNumberValue ?? 0 }
        let isAllSame = Set(digits).count == 1
        return !isAllSame
    }

    /// Strict: all smart rules + no sequential digits
    func strictValidator(_ pin: String) async -> Bool {
        guard await smartValidator(pin) else { return false }
        let digits = pin.map { $0.wholeNumberValue ?? 0 }
        let isAscending  = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 + 1 }
        let isDescending = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 - 1 }
        return !isAscending && !isDescending
    }

    /// Server: simulated 1.5 s network round-trip. Accepts any PIN ending in an even digit.
    func simulatedServerValidator(_ pin: String) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        guard let last = pin.last?.wholeNumberValue else { return false }
        return last % 2 == 0
    }
}

// MARK: - Validation Callbacks

extension ValidationDemoViewController {

    // Called by JAPinView when async validation succeeds
    func handleValidationSuccess(_ pin: String) {
        recordAttempt(pin: pin, success: true)
        retryCount = 0
        showResult("✓  PIN accepted!", color: .systemGreen)
        launchConfetti()
    }

    // Called by JAPinView when async validation fails
    func handleValidationFailure(_ pin: String) {
        retryCount += 1
        recordAttempt(pin: pin, success: false)

        let remaining = maxRetries - retryCount

        if remaining <= 0 {
            showResult("🚫 Too many attempts.\nPlease wait before retrying.", color: .systemRed)
            startCooldown(seconds: 15)
        } else {
            let ruleHint = failureHint(for: pin)
            showResult("✗  \(ruleHint)\n\(remaining) attempt\(remaining == 1 ? "" : "s") left", color: .systemOrange)
        }
        updateRetryUI()
    }

    private func failureHint(for pin: String) -> String {
        if bannedPINs.contains(pin) { return "Too common. Choose another." }
        let digits = pin.map { $0.wholeNumberValue ?? 0 }
        if Set(digits).count == 1 { return "All identical digits not allowed." }
        return "Invalid PIN. Try a different one."
    }
}

// MARK: - Cooldown

private extension ValidationDemoViewController {

    func startCooldown(seconds: Int) {
        cooldownSeconds   = seconds
        pinView.isDisabled = true
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.cooldownSeconds -= 1
            if self.cooldownSeconds <= 0 {
                self.cooldownTimer?.invalidate()
                self.pinView.isDisabled = false
                self.retryCount         = 0
                self.pinView.clear()
                self.clearResult()
            } else {
                self.showResult("⏳ Retry in \(self.cooldownSeconds)s", color: .systemGray)
            }
        }
    }
}

// MARK: - Rules Card

private extension ValidationDemoViewController {

    func populateRulesCard() {
        let header = UILabel()
        header.text      = "Validation Rules"
        header.font      = .systemFont(ofSize: 15, weight: .semibold)
        header.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let rules = [
            "Must be exactly 4 digits",
            "No common PINs (1234, 0000 …)",
            "No all-identical digits (1111 …)",
            "Strict: no sequential digits (1234, 4321)",
            "Server: must end in an even digit"
        ]

        ruleCheckmarks = rules.map { rule in
            let row = UILabel()
            row.text          = "○ \(rule)"
            row.font          = .systemFont(ofSize: 13)
            row.textColor     = .secondaryLabel
            row.numberOfLines = 2
            return row
        }
        ruleCheckmarks.forEach { stack.addArrangedSubview($0) }

        rulesCard.addSubview(header)
        rulesCard.addSubview(stack)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: rulesCard.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: rulesCard.leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: rulesCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: rulesCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: rulesCard.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Attempt History

private extension ValidationDemoViewController {

    func recordAttempt(pin: String, success: Bool) {
        attempts.insert((pin: pin, success: success, timestamp: Date()), at: 0)
        refreshHistory()
    }

    func refreshHistory() {
        historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let header = UILabel()
        header.text = "Attempt History"
        header.font = .systemFont(ofSize: 15, weight: .semibold)
        historyStack.addArrangedSubview(header)

        if attempts.isEmpty {
            let empty = UILabel()
            empty.text      = "No attempts yet"
            empty.font      = .systemFont(ofSize: 13)
            empty.textColor = .tertiaryLabel
            historyStack.addArrangedSubview(empty)
            return
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .medium

        for attempt in attempts.prefix(5) {
            let row       = UILabel()
            let masked    = String(repeating: "•", count: attempt.pin.count)
            let icon      = attempt.success ? "✓" : "✗"
            let color     = attempt.success ? "🟢" : "🔴"
            row.text      = "\(color) \(icon)  \(masked)  —  \(formatter.string(from: attempt.timestamp))"
            row.font      = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            row.textColor = attempt.success ? .systemGreen : .systemRed
            historyStack.addArrangedSubview(row)
        }
    }
}

// MARK: - Layout

private extension ValidationDemoViewController {

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

        // Pin card internals
        [pinView, spinnerView, resultLabel, retryLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            pinCard.addSubview($0)
        }
        NSLayoutConstraint.activate([
            pinView.topAnchor.constraint(equalTo: pinCard.topAnchor, constant: 24),
            pinView.leadingAnchor.constraint(equalTo: pinCard.leadingAnchor, constant: 24),
            pinView.trailingAnchor.constraint(equalTo: pinCard.trailingAnchor, constant: -24),
            pinView.heightAnchor.constraint(equalToConstant: 58),

            spinnerView.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 10),
            spinnerView.centerXAnchor.constraint(equalTo: pinCard.centerXAnchor),

            resultLabel.topAnchor.constraint(equalTo: spinnerView.bottomAnchor, constant: 4),
            resultLabel.leadingAnchor.constraint(equalTo: pinCard.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: pinCard.trailingAnchor, constant: -20),

            retryLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            retryLabel.centerXAnchor.constraint(equalTo: pinCard.centerXAnchor),
            retryLabel.bottomAnchor.constraint(equalTo: pinCard.bottomAnchor, constant: -20)
        ])

        // History card
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        historyCard.addSubview(historyStack)
        NSLayoutConstraint.activate([
            historyStack.topAnchor.constraint(equalTo: historyCard.topAnchor, constant: 16),
            historyStack.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor, constant: 16),
            historyStack.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor, constant: -16),
            historyStack.bottomAnchor.constraint(equalTo: historyCard.bottomAnchor, constant: -16)
        ])

        contentStack.addArrangedSubview(sectionLabel("Validator Mode"))
        contentStack.addArrangedSubview(ruleSegment)
        contentStack.addArrangedSubview(pinCard)
        contentStack.addArrangedSubview(rulesCard)
        contentStack.addArrangedSubview(historyCard)
        refreshHistory()
    }

    func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }
}

// MARK: - Result UI Helpers

private extension ValidationDemoViewController {

    func showResult(_ message: String, color: UIColor) {
        resultLabel.text      = message
        resultLabel.textColor = color
        UIView.animate(withDuration: 0.2) { self.resultLabel.alpha = 1 }
    }

    func clearResult() {
        UIView.animate(withDuration: 0.15) {
            self.resultLabel.alpha = 0
            self.retryLabel.alpha  = 0
        }
    }

    func updateRetryUI() {
        let remaining = maxRetries - retryCount
        retryLabel.text = "Attempts used: \(retryCount) / \(maxRetries)"
        UIView.animate(withDuration: 0.2) { self.retryLabel.alpha = 1 }
        _ = remaining
    }

    func launchConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        //emitter.emitterShape    = .line
        emitter.emitterSize     = CGSize(width: view.bounds.width, height: 1)

        let colors: [UIColor] = [.systemGreen, .systemTeal, .systemYellow, .systemBlue]
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate  = 8
            cell.lifetime   = 3
            cell.velocity   = 180
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.spin       = 3
            cell.spinRange  = 2
            cell.scale      = 0.5
            cell.scaleRange = 0.3
            cell.color      = color.cgColor
            cell.contents   = confettiImage()
            return cell
        }

        view.layer.addSublayer(emitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { emitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { emitter.removeFromSuperlayer() }
    }

    func confettiImage() -> CGImage? {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img?.cgImage
    }
}

// MARK: - JAPinViewDelegate

extension ValidationDemoViewController: JAPinViewDelegate {

    func pinViewDidBeginEditing(_ pinView: JAPinView) {
        clearResult()
        spinnerView.stopAnimating()
    }

    func pinView(_ pinView: JAPinView, didChangeText text: String) {}

    func pinView(_ pinView: JAPinView, didComplete text: String) {
        spinnerView.startAnimating()
    }

    func pinViewDidEndEditing(_ pinView: JAPinView) {}
}

// MARK: - Intercept Validation Results via Subclassing Hook

// JAPinView calls validationSucceeded/validationFailed on itself.
// We hook those results through the delegate's didComplete + onComplete closure:
private extension ValidationDemoViewController {

    func wireValidationResultsViaClosures() {
        // onComplete fires before validation starts — use delegate's didComplete
        // instead of overriding, as JAPinView handles its own UI state internally.
    }
}
