//
//  PrescriptionController.swift
//  MedCount
//
//  Created by Mathew Miller on 10/30/21.
//

import UIKit
import CoreData

private enum DeliveryType: Int {
    case ml
    case tablet
    
    var labelText: String {
        switch self {
        case .ml:
            return "mg per ml"
        case .tablet:
            return "mg per tablet"
        }
    }
}

class PrescriptionController: UIViewController {
    
    @IBOutlet weak var drugName: UITextField!
    @IBOutlet weak var milligrams: UITextField!
    @IBOutlet weak var deliveryTypeSelector: UISegmentedControl!
    @IBOutlet weak var units: UITextField!
    
    @IBOutlet weak var currentCount: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mgPerUnitLabel: UILabel!
    
    private var prescription: Prescription?
    private var patient: Patient?
    //Initialized in viewDidLoad - treat it like an IBOutlet
    var diffableDataSource: UITableViewDiffableDataSource<Int, ConsumptionRecord>!
    
    lazy var consumptionRecordsController: NSFetchedResultsController<ConsumptionRecord>? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let container = appDelegate.persistentContainer
        
        do {
            let result = try ConsumptionRecord.fetchedResultsController(in: container.viewContext, sortedBy: [("date", false)])
            
            if let prescription = prescription {
                result.fetchRequest.predicate = NSPredicate(format: "prescription = %@", prescription)
                let sort = NSSortDescriptor(key: "date", ascending: false)
                result.fetchRequest.sortDescriptors = [sort]
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
        
        drugName.delegate = self
        milligrams.delegate = self
        units.delegate = self
        currentCount.delegate = self
        
        diffableDataSource = UITableViewDiffableDataSource<Int, ConsumptionRecord>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConsumptionCell", for: indexPath)

            var text = ""
            if let date = item.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                text = formatter.string(from: date)
            }
            
            text = "\(item.amount) - \(text)"

            cell.textLabel?.text = text
            return cell
        }
        
        if let prescription = prescription {
            title = prescription.name
            drugName.text = prescription.name
            if prescription.ml > 0 {
                units.text = "\(prescription.ml)"
            }
        } else {
            title = "New Prescription"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? consumptionRecordsController?.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    func setupWith(prescription: Prescription) {
        self.prescription = prescription
    }

    func setupWith(patient: Patient?) {
        self.patient = patient
    }
    
    
    @IBAction func deliveryModeChanged(_ sender: UISegmentedControl) {
        guard let deliveryType = DeliveryType(rawValue: sender.selectedSegmentIndex) else {
            print("Delivery type selector switch is misconfigured")
            return
        }
        mgPerUnitLabel.text = deliveryType.labelText
        
    }
    
    
    @IBAction func addNewConsumptionRecord(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        if let newRecord = try? ConsumptionRecord.new(mainThreadContext) {
            newRecord.prescription = prescription
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConsumptionRecord") as! ConsumptionRecordController
            controller.setup(withConsumptionRecord: newRecord)

            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func savePrescription(_ sender: Any) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        mainThreadContext.perform {[weak self] in
            guard let self = self else {return}

            if let prescription = self.prescription {
                if let conc = self.units.text, let fconc = Float(conc) {
                    prescription.ml = fconc
                }
                
                prescription.name = self.drugName.text ?? ""
                
                
                
                
                                
            } else if let prescription = try? Prescription.new(mainThreadContext) {
                if let conc = self.units.text, let fconc = Float(conc) {
                    
                    if self.deliveryTypeSelector.selectedSegmentIndex == 0 {
                        prescription.ml = fconc
                    } else {
                        prescription.tablet = fconc
                    }
                }
                
                prescription.name = self.drugName.text ?? ""

                prescription.patient = self.patient
                self.prescription = prescription
            }

            do {
                try mainThreadContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension PrescriptionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConsumptionRecord") as! ConsumptionRecordController
        if let consumption = consumptionRecordsController?.object(at: indexPath) {
            controller.setup(withConsumptionRecord: consumption)
        }

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PrescriptionController: UITextFieldDelegate, UITextViewDelegate {
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        savePrescription(textField)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        savePrescription(textView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        savePrescription(textField)
        textField.resignFirstResponder()
        return true
    }
    
}


extension PrescriptionController: NSFetchedResultsControllerDelegate {
    
    func updateSnapshot() {
        guard let fetchedResultsController = consumptionRecordsController else {return}
        
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, ConsumptionRecord>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(diffableDataSourceSnapshot)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}


