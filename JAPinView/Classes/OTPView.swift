//
//  OTPView.swift
//  UIDemo
//
//  Created by Jayachandra on 10/31/18.
//  Copyright © 2018 BlueRose Technologies Pvt Ltd. All rights reserved.
//

import UIKit


@available(iOS 9.0, *)
@IBDesignable
class OTPView: UIView {

    private var stackView = UIStackView()
    
    
    @IBInspectable
    var numberOfFields: Int = 4
    
    @IBInspectable
    var placeholderChar: String = "*"
    
    @IBInspectable
    var fieldSpacing: CGFloat = 10 {
        didSet{
            stackView.spacing = fieldSpacing
        }
    }
    
    @IBInspectable
    var fieldBackgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.4)
    
    open var onSuccessCodeEnter: ((_ code: String)->Void)?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initilize()
    }
    
    func initilize() {
        
        let requiredFieldBoxSize = bounds.width - (CGFloat(numberOfFields)*fieldSpacing)
        assert(requiredFieldBoxSize > fieldSpacing, "Pin text box area should be greater than 'fieldSpacing' property value")
        stackView.removeFromSuperview()
        addSubview(stackView)
        stackView.anchorAllEdgesToSuperview()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = fieldSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: fieldSpacing, bottom: 0, right: fieldSpacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        var fields = [OTPTextField]()
        for _ in 0...numberOfFields {
            let field = OTPTextField()
            field.borderStyle = .roundedRect
            field.placeholder = placeholderChar
            field.keyboardType = .phonePad
            field.isSecureTextEntry = true
            field.backgroundColor = fieldBackgroundColor
            field.textAlignment = .center
            stackView.addArrangedSubview(field)
            fields.append(field)
        }
        
        for (index, item) in fields.enumerated() {
            item.fields = fields
            if index == numberOfFields{
                item.completion = { passCode in
                    if let lCompletion = self.onSuccessCodeEnter{
                        lCompletion(passCode)
                    }
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
