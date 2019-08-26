//
//  ViewController.swift
//  JAPinView
//
//  Created by JayachandraA on 11/05/2018.
//  Copyright (c) 2018 JayachandraA. All rights reserved.
//

import UIKit
import JAPinView

class ViewController: UIViewController {

    @IBOutlet weak var pinView: JAPinView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pinView.setFont(UIFont.systemFont(ofSize: 25))
        pinView.onSuccessCodeEnter = { pin in
            print(pin)
//            self.alert(pin: pin)
        }
    
    }
    
    func alert(pin: String){
        let alert = UIAlertController(title: "OTP", message: "Entered pin is '\(pin)'", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

