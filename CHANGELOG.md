# Changelog

All notable changes to JAPinView will be documented in this file.  
This project adheres to [Semantic Versioning](https://semver.org).

---

## [1.0.0] — 2026-04-08

### Added
- `JAPinView` — main `UIControl` subclass with full PIN / OTP input handling
- `JAPinConfiguration` — single config struct composing all sub-configs
- **5 built-in styles** via `JAPinStyle`:
  - `.boxed` — solid border rectangle
  - `.underlined` — bottom line only
  - `.rounded` — full pill shape
  - `.filled` — tinted background, no border
  - `.custom(JAPinCellStyle)` — fully custom renderer
- `JAPinTheme` — per-state colours: empty, focused, filled, error, cursor
- `JAPinAppearance` — font, spacing, corner radius, cursor width
- `JAPinBehavior` — keyboard type, secure entry, paste, SMS autofill, backspace
- `JAPinAnimation` — independent animation type per event (focus / entry / error)
- `JAPinAnimator` — concrete animations: `scale`, `bounce`, `fade`, `shake`, `none`
- `JAPinAccessibility` — VoiceOver per-cell labels + completion announcement
- `JAPinCellState` — `empty | focused | filled | error | disabled`
- `JAPinCellStyle` protocol — custom cell renderer with built-in `JAPinBoxedCellStyle` and `JAPinUnderlinedCellStyle`
- `JAPinViewDelegate` — `didBeginEditing`, `didChangeText`, `didComplete`, `didEndEditing`
- `setValidator(_:)` — attach an `async (String) -> Bool` closure; view manages loading, success, and failure states automatically
- `isDisabled` public property — locks the field and renders all cells in `.disabled` state
- `JAPinCursorAnimator` — `CABasicAnimation` blink controller for the active cell cursor
- `String+SafeIndex` — safe `Character` subscript to prevent index out-of-range crashes
- Blinking cursor on the active (focused) cell
- Haptic feedback on digit entry (light) and validation success (medium)
- `UINotificationFeedbackGenerator` error haptic on validation failure
- SMS AutoFill support via `textContentType = .oneTimeCode`
- Paste permission enforced in `HiddenInputTextField.canPerformAction`
- Cut / copy / select suppressed in the hidden input field
- Per-cell `accessibilityLabel` from `JAPinAccessibility.digitLabelFormat`
- `UIAccessibility.Notification.announcement` on PIN completion
- Keyboard toolbar with dismiss button (`checkmark.circle.fill`)
- `previousState` tracking on each cell — animations fire only on actual state transitions
