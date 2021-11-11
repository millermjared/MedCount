//
//  ViewExtensions.swift
//  MedCount
//
//  Created by Mathew Miller on 11/8/21.
//

import UIKit

extension UITextView {
    
    func addDoneButton(title: String? = "Done", target: Any? = self, selector: Selector? = #selector(resignFirstResponder)) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar
    }
}

extension UITextField {
    
    func addDoneButton(title: String? = "Done", target: Any? = self, selector: Selector? = #selector(resignFirstResponder)) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}

