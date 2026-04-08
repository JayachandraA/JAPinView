//
//  ThemingDemoViewController.swift
//
//  Use-case: Interactive gallery showing all JAPinStyle variants
//  (boxed, underlined, rounded, filled, custom) with live switching,
//  a colour-theme picker, and a length stepper — all without reloading the VC.
//

import UIKit
import JAPinView

final class ThemingDemoViewController: UIViewController {

    // MARK: - State

    private var selectedStyle: JAPinStyle = .boxed {
        didSet { applyCurrentConfiguration() }
    }

    private var selectedThemeIndex = 0 {
        didSet { applyCurrentConfiguration() }
    }

    private var pinLength = 4 {
        didSet { applyCurrentConfiguration() }
    }

    private var isSecure = false {
        didSet { applyCurrentConfiguration() }
    }

    // MARK: - Themes palette

    private struct ColorTheme {
        let name: String
        let focused: UIColor
        let filled: UIColor
        let cursor: UIColor
    }

    private let themes: [ColorTheme] = [
        ColorTheme(name: "Indigo",   focused: .systemIndigo,  filled: .systemIndigo,  cursor: .systemIndigo),
        ColorTheme(name: "Emerald",  focused: .systemGreen,   filled: .systemGreen,   cursor: .systemGreen),
        ColorTheme(name: "Crimson",  focused: .systemRed,     filled: .systemRed,     cursor: .systemRed),
        ColorTheme(name: "Amber",    focused: .systemOrange,  filled: .systemOrange,  cursor: .systemOrange),
        ColorTheme(name: "Violet",   focused: .systemPurple,  filled: .systemPurple,  cursor: .systemPurple),
    ]

    // MARK: - UI

    private let scrollView        = UIScrollView()
    private let contentStack      = UIStackView()
    private let previewCard       = UIView()
    private let pinView           = JAPinView()
    private let styleSegment      = UISegmentedControl()
    private let themeSegment      = UISegmentedControl()
    private let lengthStepper     = UIStepper()
    private let lengthLabel       = UILabel()
    private let secureSwitchRow   = UIView()
    private let secureSwitch      = UISwitch()
    private let enteredPINLabel   = UILabel()
    private let clearButton       = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupControls()
        applyCurrentConfiguration()
    }
}

// MARK: - View Setup

private extension ThemingDemoViewController {

    func setupView() {
        title = "Theming Demo"
        view.backgroundColor = .systemGroupedBackground

        scrollView.alwaysBounceVertical = true

        contentStack.axis      = .vertical
        contentStack.spacing   = 20
        contentStack.alignment = .fill

        // Preview card
        previewCard.backgroundColor    = .systemBackground
        previewCard.layer.cornerRadius = 16
        previewCard.layer.shadowColor  = UIColor.black.cgColor
        previewCard.layer.shadowOpacity = 0.07
        previewCard.layer.shadowRadius  = 12
        previewCard.layer.shadowOffset  = CGSize(width: 0, height: 3)

        // Entered PIN
        enteredPINLabel.font          = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        enteredPINLabel.textColor     = .tertiaryLabel
        enteredPINLabel.textAlignment = .center
        enteredPINLabel.text          = "Enter digits above"

        pinView.onChange = { [weak self] pin in
            self?.enteredPINLabel.text = pin.isEmpty ? "Enter digits above" : "PIN: \(pin)"
        }

        // Clear button
        clearButton.setTitle("Clear", for: .normal)
        clearButton.tintColor = .systemRed
        clearButton.addAction(UIAction { [weak self] _ in
            self?.pinView.clear()
        }, for: .touchUpInside)
    }

    func setupControls() {
        // Style picker
        let styles = ["Boxed", "Underlined", "Rounded", "Filled", "Custom"]
        styles.enumerated().forEach { i, s in styleSegment.insertSegment(withTitle: s, at: i, animated: false) }
        styleSegment.selectedSegmentIndex = 0
        styleSegment.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            switch self.styleSegment.selectedSegmentIndex {
            case 0: self.selectedStyle = .boxed
            case 1: self.selectedStyle = .underlined
            case 2: self.selectedStyle = .rounded
            case 3: self.selectedStyle = .filled
            case 4: self.selectedStyle = .custom(GlassmorphicCellStyle())
            default: break
            }
        }, for: .valueChanged)

        // Theme picker
        themes.enumerated().forEach { i, t in themeSegment.insertSegment(withTitle: t.name, at: i, animated: false) }
        themeSegment.selectedSegmentIndex = 0
        themeSegment.addAction(UIAction { [weak self] _ in
            self?.selectedThemeIndex = self?.themeSegment.selectedSegmentIndex ?? 0
        }, for: .valueChanged)

        // Length stepper
        lengthStepper.minimumValue = 4
        lengthStepper.maximumValue = 8
        lengthStepper.stepValue    = 1
        lengthStepper.value        = 4
        updateLengthLabel()
        lengthStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.pinLength = Int(self.lengthStepper.value)
            self.updateLengthLabel()
        }, for: .valueChanged)

        // Secure switch
        secureSwitch.addAction(UIAction { [weak self] _ in
            self?.isSecure = self?.secureSwitch.isOn ?? false
        }, for: .valueChanged)
    }

    func updateLengthLabel() {
        lengthLabel.text = "Length: \(pinLength)"
    }
}

// MARK: - Layout

private extension ThemingDemoViewController {

    func setupLayout() {
        [scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        // Preview card containing pinView + label + clear
        previewCard.translatesAutoresizingMaskIntoConstraints = false
        [pinView, enteredPINLabel, clearButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            previewCard.addSubview($0)
        }
        NSLayoutConstraint.activate([
            pinView.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 28),
            pinView.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 24),
            pinView.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -24),
            pinView.heightAnchor.constraint(equalToConstant: 60),

            enteredPINLabel.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 10),
            enteredPINLabel.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),

            clearButton.topAnchor.constraint(equalTo: enteredPINLabel.bottomAnchor, constant: 8),
            clearButton.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),
            clearButton.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -20)
        ])

        // Length stepper row
        let lengthRow = makeRow(label: lengthLabel, control: lengthStepper)

        // Secure row
        let secureTitleLabel = UILabel()
        secureTitleLabel.text = "Secure entry (•)"
        secureTitleLabel.font = .systemFont(ofSize: 15)
        let secureRow = makeRow(label: secureTitleLabel, control: secureSwitch)

        // Section headers
        [previewCard,
         sectionHeader("Style"),
         styleSegment,
         sectionHeader("Colour Theme"),
         themeSegment,
         sectionHeader("Options"),
         lengthRow,
         secureRow
        ].forEach { contentStack.addArrangedSubview($0) }
    }

    func sectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text      = text.uppercased()
        l.font      = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    func makeRow(label: UIView, control: UIView) -> UIView {
        let row = UIView()
        [label, control].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            control.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 44)
        ])
        return row
    }
}

// MARK: - Configuration Builder

private extension ThemingDemoViewController {

    func applyCurrentConfiguration() {
        let theme = themes[selectedThemeIndex]

        var config = JAPinConfiguration(
            pinLength: pinLength,
            style: selectedStyle,
            appearance: {
                var a = JAPinAppearance.default
                a.font        = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
                a.cursorColor = theme.cursor
                return a
            }(),
            behavior: JAPinBehavior(
                keyboardType: .numberPad,
                isSecureEntry: isSecure,
                secureSymbol: "●",
                autoFocus: false,
                autoSubmit: false,
                allowsPaste: true,
                enablesAutoFill: false,
                deleteBackwardMovesFocus: true
            ),
            animation: JAPinAnimation(
                focus: .scale,
                textEntry: .bounce,
                error: .shake
            ),
            accessibility: .default
        )

        config.theme.focusedBorderColor = theme.focused
        config.theme.filledBorderColor  = theme.filled
        config.theme.cursorColor        = theme.cursor

        pinView.configuration = config
    }
}

// MARK: - GlassmorphicCellStyle (Custom JAPinCellStyle demo)

/// A frosted-glass style used when "Custom" is selected.
private final class GlassmorphicCellStyle: JAPinCellStyle {

    func apply(to view: UIView, state: JAPinCellState) {
        view.layer.borderWidth   = 1
        view.layer.cornerRadius  = 14
        view.clipsToBounds       = true

        switch state {
        case .focused:
            view.backgroundColor    = UIColor.systemPurple.withAlphaComponent(0.18)
            view.layer.borderColor  = UIColor.systemPurple.cgColor
        case .filled:
            view.backgroundColor    = UIColor.systemPurple.withAlphaComponent(0.10)
            view.layer.borderColor  = UIColor.systemPurple.withAlphaComponent(0.6).cgColor
        case .error:
            view.backgroundColor    = UIColor.systemRed.withAlphaComponent(0.12)
            view.layer.borderColor  = UIColor.systemRed.cgColor
        case .empty:
            view.backgroundColor    = UIColor.white.withAlphaComponent(0.07)
            view.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        case .disabled:
            view.backgroundColor    = UIColor.systemGray5.withAlphaComponent(0.3)
            view.layer.borderColor  = UIColor.systemGray4.cgColor
            view.alpha              = 0.5
        }

        // Blur effect
        view.subviews.compactMap { $0 as? UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        let blur   = UIBlurEffect(style: .systemUltraThinMaterial)
        let effect = UIVisualEffectView(effect: blur)
        effect.frame = view.bounds
        effect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(effect, at: 0)
    }
}
