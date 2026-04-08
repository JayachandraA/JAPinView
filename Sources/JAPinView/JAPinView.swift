//
//  JAPinView.swift
//
//  A fully customizable, accessible, and validation-ready PIN/OTP input component.
//
//  Features:
//  - Secure or visible digit entry
//  - AutoFill OTP support
//  - Async validation
//  - Accessibility optimized
//  - Error & loading states
//  - Delegate + Closure callbacks
//  - Haptic feedback
//
//  Designed for production authentication flows.
//

import UIKit

// MARK: - JAPinView

/**
 `JAPinView` is a customizable PIN / OTP input control.

 The view renders individual digit cells while internally using a hidden
 `UITextField` to handle keyboard input.

 Responsibilities:
 - Manages PIN text input
 - Updates visual cell states
 - Handles validation lifecycle
 - Provides accessibility announcements
 - Emits delegate & closure callbacks

 Example:
    ```
        let pinView = JAPinView()
        pinView.onComplete = { pin in
            print("Entered PIN:", pin)
        }
    ```
*/
public final class JAPinView: UIControl {

   // MARK: Public API

   /// Delegate receiving PIN lifecycle callbacks.
   public weak var delegate: JAPinViewDelegate?

   /**
    Current entered PIN text.

    Automatically:
    - Sends `.valueChanged`
    - Notifies delegate & closures
    - Triggers validation when complete
    */
   public private(set) var text: String = "" {
       didSet {
           sendActions(for: .valueChanged)

           delegate?.pinView(self, didChangeText: text)
           onChange?(text)

           // Fire completion only when newly completed
           if isComplete && oldValue != text {
               onComplete?(text)
               delegate?.pinView(self, didComplete: text)

               validationCoordinator.validate(text)

               if configuration.accessibility.announcesCompletion {
                   UIAccessibility.post(
                       notification: .announcement,
                       argument: "PIN entry complete"
                   )
               }
           }
       }
   }

   /// Called whenever text changes.
   public var onChange: ((String) -> Void)?

   /// Called when PIN entry reaches required length.
   public var onComplete: ((String) -> Void)?

   /// Disables interaction and shows disabled UI state.
   public var isDisabled: Bool = false {
       didSet {
           isUserInteractionEnabled = !isDisabled
           updateUI()
       }
   }

   /// Returns true when PIN length requirement is met.
   public var isComplete: Bool {
       text.count == configuration.pinLength
   }

   /**
    Configuration controlling appearance, behavior, and accessibility.
    Rebuilds UI if pin length changes.
    */
   public var configuration: JAPinConfiguration {
       didSet {
           guard oldValue.pinLength != configuration.pinLength else {
               updateUI()
               return
           }
           rebuild()
       }
   }

   // MARK: Private Properties

   /// Handles async validation workflow.
   private lazy var validationCoordinator =
       JAPinValidationCoordinator(pinView: self)

   private var isLoading = false
   private var isErrorState = false

   /// Container holding digit cells.
   private let stackView = UIStackView()

   /// Hidden input field capturing keyboard input.
   private let inputField = HiddenInputTextField()

   /// Visible PIN cells.
   private var cells: [JAPinCellView] = []

   // MARK: Initialization

   public init(configuration: JAPinConfiguration = .default) {
       self.configuration = configuration
       super.init(frame: .zero)
       setup()
   }

   required init?(coder: NSCoder) {
       self.configuration = .default
       super.init(coder: coder)
       setup()
   }
}

// MARK: - Setup

private extension JAPinView {

   /// Performs initial view setup.
   func setup() {

       // Cells act as accessibility elements individually.
       isAccessibilityElement = false

       configureStack()
       configureInputField()
       rebuild()

       if configuration.behavior.autoFocus {
           DispatchQueue.main.async { self.focus() }
       }

       inputField.onKeyboardClosed = { [weak self] in
           self?.cells.forEach { $0.hideCursor() }
           self?.updateUI()
       }
   }

   /// Configures horizontal stack layout.
   func configureStack() {
       stackView.axis = .horizontal
       stackView.distribution = .fillEqually
       stackView.spacing = configuration.appearance.spacing

       addSubview(stackView)
       stackView.translatesAutoresizingMaskIntoConstraints = false

       NSLayoutConstraint.activate([
           stackView.topAnchor.constraint(equalTo: topAnchor),
           stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
           stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
           stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
       ])
   }

   /// Configures hidden keyboard input field.
   func configureInputField() {

       inputField.keyboardType = configuration.behavior.keyboardType
       inputField.textContentType =
           configuration.behavior.enablesAutoFill ? .oneTimeCode : .none

       inputField.allowsPaste = configuration.behavior.allowsPaste

       inputField.tintColor = .clear
       inputField.textColor = .clear
       inputField.delegate = self

       inputField.addTarget(
           self,
           action: #selector(textFieldChanged),
           for: .editingChanged
       )

       addSubview(inputField)
       inputField.translatesAutoresizingMaskIntoConstraints = false

       NSLayoutConstraint.activate([
           inputField.topAnchor.constraint(equalTo: topAnchor),
           inputField.bottomAnchor.constraint(equalTo: bottomAnchor),
           inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
           inputField.trailingAnchor.constraint(equalTo: trailingAnchor)
       ])
   }
}

// MARK: - Build UI

private extension JAPinView {

   /// Recreates PIN cells based on configuration.
   func rebuild() {

       stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
       cells.removeAll()

       for index in 0..<configuration.pinLength {

           let cell = JAPinCellView(configuration: configuration)

           cell.isAccessibilityElement = true
           cell.accessibilityTraits = .staticText
           cell.accessibilityLabel = String(
               format: configuration.accessibility.digitLabelFormat,
               index + 1,
               configuration.pinLength
           )

           cells.append(cell)
           stackView.addArrangedSubview(cell)
       }

       updateUI()
   }
}

// MARK: - UI Updates

private extension JAPinView {

   /// Updates visual state of all PIN cells.
   func updateUI() {

       for (index, cell) in cells.enumerated() {

           let char = text[safe: index]

           let state: JAPinCellState

           if isDisabled {
               state = .disabled
           } else if isErrorState {
               state = .error
           } else if inputField.isFirstResponder && index == text.count {
               state = .focused
           } else if char != nil {
               state = .filled
           } else {
               state = .empty
           }

           let display: String?
           if let char {
               display = configuration.behavior.isSecureEntry
                   ? configuration.behavior.secureSymbol
                   : String(char)
           } else {
               display = nil
           }

           cell.accessibilityValue =
               display != nil ? "filled" : "empty"

           cell.update(character: display, state: state)
       }
   }
}

// MARK: - Public Control API

public extension JAPinView {

   /// Focus keyboard input.
   func focus() {
       inputField.becomeFirstResponder()
   }

   /// Remove keyboard focus.
   func resignFocus() {
       inputField.resignFirstResponder()
   }

   /// Clears entered PIN.
   func clear() {
       text = ""
       inputField.text = ""
       isErrorState = false
       updateUI()
   }

   /// Triggers error animation.
   func shake() {
       showError(animated: true)
   }

   /// Enables or disables error UI state.
   func setErrorState(_ enabled: Bool) {
       isErrorState = enabled
       updateUI()
   }

   /// Shows loading state and disables interaction.
   func setLoading(_ loading: Bool) {
       isLoading = loading
       isUserInteractionEnabled = !loading
       alpha = loading ? 0.6 : 1.0
   }

   /// Attach async validator executed when PIN completes.
   func setValidator(_ validator: @escaping (String) async -> Bool) {
       validationCoordinator.validator = validator
   }

   /// Called when validation succeeds.
   func validationSucceeded() {
       UIImpactFeedbackGenerator(style: .medium).impactOccurred()
   }

   /// Called when validation fails.
   func validationFailed() {
       showError(animated: true)

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
           self.resetAfterError()
       }
   }

   /// Clears error and resets input.
   private func resetAfterError() {
       isErrorState = false
       text = ""
       inputField.text = ""
       updateUI()
       focus()
   }
}

// MARK: - Input Handling

private extension JAPinView {

   /// Triggered when hidden text field changes.
   @objc
   func textFieldChanged() {
       handleInput(inputField.text ?? "")
   }

   /// Processes raw keyboard input.
   func handleInput(_ newValue: String) {

       isErrorState = false

       var filtered: String

       switch configuration.behavior.keyboardType {
       case .numberPad, .decimalPad, .phonePad:
           filtered = newValue.filter { $0.isNumber }
       default:
           filtered = newValue
       }

       if filtered.count > configuration.pinLength {
           filtered = String(filtered.prefix(configuration.pinLength))
       }

       let oldCount = text.count

       text = filtered
       inputField.text = filtered

       updateUI()

       if text.count > oldCount {
           playEntryHaptic()
       }
   }
}

// MARK: - UITextFieldDelegate

extension JAPinView: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.pinViewDidBeginEditing(self)
        updateUI()
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.pinViewDidEndEditing(self)
        updateUI()
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let current = textField.text else { return false }

        // Handle backspace with deleteBackwardMovesFocus behavior
        if string.isEmpty && configuration.behavior.deleteBackwardMovesFocus && !current.isEmpty {
            let newText = String(current.dropLast())
            handleInput(newText)
            return false
        }

        let newText = (current as NSString).replacingCharacters(in: range, with: string)
        handleInput(newText)
        return false
    }
}

// MARK: - Error Animation

public extension JAPinView {

    /**
     Displays error state for the PIN view.

     Behavior:
     - Switches all cells into `.error` state
     - Triggers haptic feedback
     - Runs configured error animation on each cell

     - Parameter animated: Whether animation should run.
     */
    func showError(animated: Bool = true) {
        isErrorState = true
        updateUI()

        guard animated else { return }

        print("Show error-")

        // System error haptic feedback
        UINotificationFeedbackGenerator()
            .notificationOccurred(.error)

        // Execute configured animation
        cells.forEach {
            JAPinAnimator.animate(configuration.animation.error, on: $0)
        }
    }
}

// MARK: - Haptics

private extension JAPinView {

    /// Plays light haptic feedback when a digit is entered.
    func playEntryHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - HiddenInputTextField

/**
 A hidden UITextField used purely for keyboard input.

 Responsibilities:
 - Captures keyboard typing
 - Hides caret and selection UI
 - Controls paste permissions
 - Provides custom keyboard toolbar
 */
final class HiddenInputTextField: UITextField {

    /// Determines whether paste action is allowed.
    var allowsPaste: Bool = true

    /// Called when keyboard is dismissed via accessory button.
    var onKeyboardClosed: (() -> Void)?

    /// Hide caret completely.
    override func caretRect(for position: UITextPosition) -> CGRect { .zero }

    /// Disable text selection visuals.
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { [] }

    /**
     Restricts editing actions to keep field invisible and controlled.
     */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        if action == #selector(paste(_:)) { return allowsPaste }
        if action == #selector(cut(_:))       { return false }
        if action == #selector(copy(_:))      { return false }
        if action == #selector(select(_:))    { return false }
        if action == #selector(selectAll(_:)) { return false }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: Init

    init() {
        super.init(frame: .zero)

        // Toolbar with Done button
        let toolBar = UIToolbar()
        toolBar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(
                image: UIImage(systemName: "checkmark.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(resignKeyboard)
            )
        ]

        toolBar.sizeToFit()
        inputAccessoryView = toolBar
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Dismiss keyboard and notify listener.
    @objc
    func resignKeyboard() {
        resignFirstResponder()
        onKeyboardClosed?()
    }
}

// MARK: - JAPinCellView

/**
 Represents a single PIN digit cell.

 Responsibilities:
 - Displays character or secure symbol
 - Shows cursor when focused
 - Applies styling based on state
 - Runs animations on transitions
 */
final class JAPinCellView: UIView {

    private let label = UILabel()
    private let cursor = UIView()
    private let configuration: JAPinConfiguration

    /// Cursor blink animator.
    private lazy var cursorAnimator = JAPinCursorAnimator(cursor: cursor)

    /// Bottom border used only in `.underlined` style.
    private lazy var bottomBorderLayer: CALayer = {
        let layer = CALayer()
        self.layer.addSublayer(layer)
        return layer
    }()

    /// Tracks last state to avoid duplicate animations.
    private var previousState: JAPinCellState?

    // MARK: Init

    init(configuration: JAPinConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Setup

    private func setup() {
        applyStaticStyle()

        label.font = configuration.appearance.font
        label.textColor = configuration.appearance.textColor
        label.textAlignment = .center
        addSubview(label)

        cursor.backgroundColor = configuration.theme.cursorColor
        cursor.isHidden = true
        cursor.layer.opacity = 1
        addSubview(cursor)
    }

    /**
     Applies style-dependent static appearance.
     */
    private func applyStaticStyle() {

        switch configuration.style {

        case .boxed:
            layer.borderWidth = configuration.theme.borderWidth
            layer.cornerRadius = configuration.appearance.cornerRadius
            backgroundColor = configuration.appearance.backgroundColor

        case .underlined:
            layer.borderWidth = 0
            layer.cornerRadius = 0
            backgroundColor = .clear

        case .rounded:
            layer.borderWidth = configuration.theme.borderWidth
            backgroundColor = configuration.appearance.backgroundColor

        case .filled:
            layer.borderWidth = 0
            layer.cornerRadius = configuration.appearance.cornerRadius
            backgroundColor = configuration.theme.backgroundColor == .clear
                ? UIColor.systemGray6
                : configuration.theme.backgroundColor

        case .custom(let style):
            style.apply(to: self, state: .empty)
        }
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        label.frame = bounds

        let cw = configuration.appearance.cursorWidth
        cursor.frame = CGRect(
            x: bounds.midX - cw / 2,
            y: bounds.height * 0.2,
            width: cw,
            height: bounds.height * 0.55
        )

        switch configuration.style {

        case .rounded:
            layer.cornerRadius = bounds.height / 2

        case .underlined:
            let height = max(configuration.theme.borderWidth, 2)
            bottomBorderLayer.frame = CGRect(
                x: 0,
                y: bounds.height - height,
                width: bounds.width,
                height: height
            )

        default:
            break
        }
    }

    /// Hides cursor and stops blinking animation.
    func hideCursor() {
        cursor.isHidden = true
        cursorAnimator.stop()
    }

    deinit {
        cursorAnimator.stop()
    }
}

// MARK: - Cell State Updates

extension JAPinCellView {

    /**
     Updates visual appearance based on cell state.
     */
    func update(character: String?, state: JAPinCellState) {

        label.text = character

        let stateChanged = previousState != state
        previousState = state

        switch state {

        case .focused:
            applyBorderColor(configuration.theme.focusedBorderColor)
            cursor.isHidden = false
            cursorAnimator.start()

            if stateChanged {
                JAPinAnimator.animate(configuration.animation.focus, on: self)
            }

        case .filled:
            applyBorderColor(configuration.theme.filledBorderColor)
            cursorAnimator.stop()
            cursor.isHidden = true

            if stateChanged {
                JAPinAnimator.animate(configuration.animation.textEntry, on: self)
            }

        case .empty:
            applyBorderColor(configuration.theme.emptyBorderColor)
            cursorAnimator.stop()
            cursor.isHidden = true

        case .error:
            applyBorderColor(configuration.theme.errorBorderColor)
            cursorAnimator.stop()
            cursor.isHidden = true

        case .disabled:
            applyBorderColor(configuration.theme.emptyBorderColor)
            cursorAnimator.stop()
            cursor.isHidden = true
            alpha = 0.5
        }

        // Filled style background animation
        if case .filled = configuration.style {
            animateFilledBackground(for: state)
        }

        // Custom style override
        if case .custom(let style) = configuration.style {
            style.apply(to: self, state: state)
        }
    }

    /// Applies error border appearance.
    func setErrorAppearance() {
        applyBorderColor(configuration.theme.errorBorderColor)
    }

    // MARK: Helpers

    /// Applies border or underline color depending on style.
    private func applyBorderColor(_ color: UIColor) {
        switch configuration.style {
        case .underlined:
            bottomBorderLayer.backgroundColor = color.cgColor
        case .filled, .custom:
            break
        default:
            layer.borderColor = color.cgColor
        }
    }

    /// Animates filled background transitions.
    private func animateFilledBackground(for state: JAPinCellState) {

        let target: UIColor

        switch state {
        case .focused:
            target = configuration.theme.focusedBorderColor.withAlphaComponent(0.12)
        case .error:
            target = configuration.theme.errorBorderColor.withAlphaComponent(0.12)
        case .disabled:
            target = UIColor.systemGray5
        default:
            target = configuration.theme.backgroundColor == .clear
                ? UIColor.systemGray6
                : configuration.theme.backgroundColor
        }

        UIView.animate(withDuration: 0.15) {
            self.backgroundColor = target
        }
    }
}
