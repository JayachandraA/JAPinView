//
//  JATextField.swift
//  UIDemo
//
//  Created by Jayachandra on 10/31/18.
//  Copyright © 2018 BlueRose Technologies Pvt Ltd. All rights reserved.
//

import UIKit

public class JATextField: UITextField, UITextFieldDelegate {

    open var fields: [JATextField]?
    
    open var completion: ((_ code: String)->Void)?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    init() {
        super.init(frame: .zero)
        initilize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initilize()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        initilize()
    }
    
    private func initilize() {
        delegate = self
    }
    
    override public func deleteBackward() {
        super.deleteBackward()
//        respondPrevious(field: self)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count > 0 {
            textField.backgroundColor = .white
        } else {
            if #available(iOS 9.0, *) {
                textField.backgroundColor = JAPinView().fieldBackgroundColor
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count > 0  else {
            textField.text = ""
            respondPrevious(field: self)
            return false
        }
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let change = prospectiveText.count == 1
        if change{
            textField.text = prospectiveText
            respondNext(field: self)
        }
        return change
    }
    
    func respondNext(field: JATextField) {
        guard let lFields = fields else {
            return
        }
        
        guard let index = lFields.index(of: field) else{
            return
        }
        
        if index == lFields.count-1 {
            var passCode = ""
            for item in lFields {
                passCode = passCode + item.text!
            }
            if let lCompletion = completion {
                lCompletion(passCode)
            }
            field.resignFirstResponder()
            return
        }
        
        lFields[index+1].becomeFirstResponder()
    }
    
    func respondPrevious(field: JATextField) {
        guard let lFields = fields else {
            return
        }

        guard let index = lFields.index(of: field) else{
            return
        }

        if index == 0 {
            lFields[index].resignFirstResponder()
            return
        }

        lFields[index-1].becomeFirstResponder()
    }
    

}
