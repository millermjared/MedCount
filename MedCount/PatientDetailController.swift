//
//  PatientDetailController.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 10/29/21.
//

import UIKit
import CoreData

class PatientDetailController: UIViewController {

    static let defaultDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 1945, month: 1, day: 1))!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var mrnNumber: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var diagnosis: UITextField!
    @IBOutlet weak var genderSelector: UISegmentedControl!
    @IBOutlet weak var nextVisitPicker: UIDatePicker!
    
    
    
    private var patient: Patient?
    //Initialized in viewDidLoad - treat it like an IBOutlet
    var diffableDataSource: UITableViewDiffableDataSource<Int, Prescription>!
    
    lazy var prescriptionResultsController: NSFetchedResultsController<Prescription>? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let container = appDelegate.persistentContainer
                
        do {
            let result = try Prescription.fetchedResultsController(in: container.viewContext, sortedBy: [("name", true)])
            
            if let patient = patient {
                result.fetchRequest.predicate = NSPredicate(format: "patient = %@", patient)
            }
            
            result.delegate = self
            
            try result.performFetch()
            
            return result
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
        name.delegate = self
        address.delegate = self
        mrnNumber.delegate = self
        
        address.layer.borderWidth = 1.0
        address.layer.borderColor = UIColor.lightGray.cgColor
        address.addDoneButton(title: "Done", target: address!, selector: #selector(resignFirstResponder))
        diffableDataSource = UITableViewDiffableDataSource<Int, Prescription>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
               let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath)
            cell.textLabel?.text = item.name
               return cell
           }
        diffableDataSource.defaultRowAnimation = .none
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? self.prescriptionResultsController?.performFetch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    func setupWith(_ patient: Patient) {
        self.patient = patient
    }

    private func updateUI() {
        if let patient = patient {

            title = patient.name
            name.text = patient.name
            address.text = patient.address
            age.text = "\(patient.age)"
            birthdatePicker.date = patient.birthdate ?? Self.defaultDate
            mrnNumber.text = patient.mrnNumber ?? ""
            genderSelector.selectedSegmentIndex = patient.gender == "female" ? 1 : 0
            diagnosis.text = patient.diagnosis
            updateSnapshot()
            
        } else {
            title = "New Patient"
        }
    }
    
    @IBAction func setNextVisitDate(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext

        if self.patient == nil {
            self.patient = try? Patient.new(mainThreadContext)
        }
        
        patient?.managedObjectContext?.performAndWait {
            patient?.nextVisit = nextVisitPicker.date
        }
        savePatient(self)
    }
    
    @IBAction func markVisited(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext

        if self.patient == nil {
            self.patient = try? Patient.new(mainThreadContext)
        }
        
        patient?.managedObjectContext?.performAndWait {
            patient?.lastVisit = Date()
        }
        savePatient(self)
    }
    
    @IBAction func savePatient(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        mainThreadContext.perform {[weak self] in
            guard let self = self else {return}
            
            if self.patient == nil {
                self.patient = try? Patient.new(mainThreadContext)
            }

            if let patient = self.patient {
                patient.name = self.name.text
                patient.address = self.address.text
                patient.birthdate = self.birthdatePicker.date
                patient.mrnNumber = self.mrnNumber.text
                patient.diagnosis = self.diagnosis.text
                patient.gender = self.genderSelector.selectedSegmentIndex == 0 ? "male" : "female"
            }
            
            do {
                try mainThreadContext.save()
                DispatchQueue.main.async {
                    self.updateUI()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func navigateToAddress(_ sender: Any) {
        if let targetAddress = patient?.address {
            var components = URLComponents(string: "http://maps.apple.com")
            components?.queryItems = [
                URLQueryItem(name: "daddr", value: targetAddress)
            ]
            if let url = components?.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PrescriptionController {
            destination.setupWith(patient: patient)
        }
    }
}

extension PatientDetailController: UITextFieldDelegate, UITextViewDelegate {
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        savePatient(textField)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        savePatient(textView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        savePatient(textField)
        textField.resignFirstResponder()
        return true
    }
    
}

extension PatientDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrescriptionDetail") as! PrescriptionController
        if let prescription = prescriptionResultsController?.object(at: indexPath) {
            controller.setupWith(prescription: prescription)
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PatientDetailController: NSFetchedResultsControllerDelegate {
    
    func updateSnapshot() {
        guard let fetchedResultsController = prescriptionResultsController else {return}
        
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Prescription>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(diffableDataSourceSnapshot)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

