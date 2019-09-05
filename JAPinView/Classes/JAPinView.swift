//
//  JAPinView.swift
//  UIDemo
//
//  Created by Jayachandra on 10/31/18.
//  Copyright © 2018 BlueRose Technologies Pvt Ltd. All rights reserved.
//

import UIKit


public protocol JAPinViewTextDelegate: class {
    func fieldDidBeginEditing(_ textField: UITextField)
}


@available(iOS 9.0, *)
@IBDesignable
public class JAPinView: UIView {

    private var stackView = UIStackView()
    private var textFeilds = [JATextField]()
    public weak var fieldDelegate: JAPinViewTextDelegate?
    
    /// Number of input field will be desided by this property.
    /// By defalut it is four boxes PinView
    @IBInspectable
    var passcodeLength: Int = 4
    
    
    /// Set your passcode placeholder to change it's default
    @IBInspectable
    var placeholderChar: String = "*"
    
    
    /// Defines the spacing between the field to field
    @IBInspectable
    var spacing: CGFloat = 10 {
        didSet{
            stackView.spacing = spacing
        }
    }
    
    
    /// The background will be shown as light gray color by default, change it to your specified color if you want.
    @IBInspectable
    var fieldBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
    
    
    
    /// Password will be showing as secured as '∙', if you set it to false then the passwoed will be shown to user
    @IBInspectable
    open var isSecure: Bool = true
    
    
    /// Set the handler to lisen the pass code value after successful enterd
    open var onSuccessCodeEnter: ((_ code: String)->Void)?

    @IBInspectable
    open var textColor: UIColor = .black
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        initilize()
    }
    
    open func setFont(_ font: UIFont) {
        for field in self.textFeilds {
            field.font = font
            field.fieldDelegate = self.fieldDelegate
        }
    }
    
    func initilize() {
        
        let requiredFieldBoxSize = bounds.width - (CGFloat(passcodeLength)*spacing)
//        assert(requiredFieldBoxSize > spacing, "Pin text box area should be greater than 'fieldSpacing' property value")
        stackView.removeFromSuperview()
        addSubview(stackView)
        stackView.anchorAllEdgesToSuperview()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        var fields = [JATextField]()
        var i = 100
        for f in 1...passcodeLength {
            let field = JATextField()
            field.tag = i
            i = i+1
            if f == 1 {
                field.becomeFirstResponder()
            }
            field.borderStyle = .roundedRect
            field.textColor = textColor
            field.placeholder = placeholderChar
            field.keyboardType = .phonePad
            field.isSecureTextEntry = false
            field.backgroundColor = fieldBackgroundColor
            field.textAlignment = .center
            stackView.addArrangedSubview(field)
            fields.append(field)
        }
        self.textFeilds = fields
        for (index, item) in fields.enumerated() {
            
            item.fields = fields
            item.completion = { passCode in
                if let lCompletion = self.onSuccessCodeEnter{
                    lCompletion(passCode)
                }
            }
        }
    }
}


extension UIView {
    
    fileprivate func anchorAllEdgesToSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            if let top = superview?.topAnchor{
                addSuperviewConstraint(constraint: topAnchor.constraint(equalTo: top))
            }
            if let left = superview?.leftAnchor{
                addSuperviewConstraint(constraint: leftAnchor.constraint(equalTo: left))
            }
            
            if let bottom = superview?.bottomAnchor{
                addSuperviewConstraint(constraint: bottomAnchor.constraint(equalTo: bottom))
            }
            
            if let right = superview?.rightAnchor{
                addSuperviewConstraint(constraint: rightAnchor.constraint(equalTo: right))
            }
        }
        else {
            for attribute : NSLayoutConstraint.Attribute in [.left, .top, .right, .bottom] {
                anchorToSuperview(attribute: attribute)
            }
        }
    }
    
    fileprivate func anchorToSuperview(attribute: NSLayoutConstraint.Attribute) {
        addSuperviewConstraint(constraint: NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: superview, attribute: attribute, multiplier: 1.0, constant: 0.0))
    }
    
    fileprivate func addSuperviewConstraint(constraint: NSLayoutConstraint?) {
        guard let lConstraint = constraint else { return }
        superview?.addConstraint(lConstraint)
    }
}
