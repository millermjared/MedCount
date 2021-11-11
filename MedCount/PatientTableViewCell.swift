//
//  PatientTableViewCell.swift
//  MedCount
//
//  Created by Mathew Miller on 11/8/21.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    var patient: Patient!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var diagnosis: UILabel!
    @IBOutlet weak var lastVisit: UILabel!
    
    
    func setup(withPatient patient: Patient) {
        self.patient = patient
        name.text = patient.name
        gender.text = patient.gender == "male" ? "(M)" : "(F)"
        age.text = "\(patient.age)"
        diagnosis.text = patient.diagnosis
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let lastVisitDate = patient.lastVisit {
            let lastVisitString = formatter.string(from: lastVisitDate)
            lastVisit.text = "\(lastVisitString)"
        } else {
            lastVisit.text = "Unvisited"
        }
    }
    
    @IBAction func navigateToAddress(_ sender: Any) {
        if let targetAddress = patient.address {
            var components = URLComponents(string: "http://maps.apple.com")
            components?.queryItems = [
                URLQueryItem(name: "daddr", value: targetAddress)
            ]
            if let url = components?.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

}
