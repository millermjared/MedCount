//
//  ConsumptionRecordController.swift
//  MedCount
//
//  Created by Mathew Miller on 10/30/21.
//

import UIKit

class ConsumptionRecordController: UIViewController {

    var consumptionRecord: ConsumptionRecord!
    
    @IBOutlet weak var recordDate: UIDatePicker!
    @IBOutlet weak var amountConsumed: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordDate.date = Date()
        amountConsumed.addDoneButton(title: "Done", target: amountConsumed!, selector: #selector(resignFirstResponder))
        amountConsumed.delegate = self
    }
    

    func setup(withConsumptionRecord consumptionRecord: ConsumptionRecord) {
        self.consumptionRecord = consumptionRecord
    }
    
    @IBAction func saveConsumption(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        mainThreadContext.perform {[weak self] in
            guard let self = self else {return}
            
            self.consumptionRecord.date = self.recordDate.date
            if let amountString = self.amountConsumed.text, let amount = Float(amountString) {
                self.consumptionRecord.amount = amount
            }
            
            do {
                try mainThreadContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension ConsumptionRecordController: UITextFieldDelegate, UITextViewDelegate {
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveConsumption(textField)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveConsumption(textView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveConsumption(textField)
        textField.resignFirstResponder()
        return true
    }
    
}
