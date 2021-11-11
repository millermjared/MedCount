//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//

import UIKit
import CoreData

class PatientListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var patientResultsController: NSFetchedResultsController<Patient>? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let container = appDelegate.persistentContainer
                
        do {
            let result = try Patient.fetchedResultsController(in: container.viewContext, sortedBy: [("name", true)])
                        
            result.delegate = self
            
            return result
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
        return nil
    }()
    
    //Initialized in viewDidLoad - treat it like an IBOutlet
    var diffableDataSource: UITableViewDiffableDataSource<Int, Patient>!
    
    override func viewDidLoad() {
        
        diffableDataSource = UITableViewDiffableDataSource<Int, Patient>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientTableViewCell
            cell.setup(withPatient: item)
            return cell
        }
        
        title = "Today's Patients"
        updateFilter(nil)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? self.patientResultsController?.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    @IBAction func updateFilter(_ sender: UISegmentedControl?) {
        
        if sender?.selectedSegmentIndex == 1 {
            patientResultsController?.fetchRequest.predicate = nil
            
        } else {
            let cal = Calendar(identifier: .gregorian)
            guard let start = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date()),
                  let end = cal.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
            else {
                patientResultsController?.fetchRequest.predicate = nil
                try? patientResultsController?.performFetch()
                return
            }
            
            patientResultsController?.fetchRequest.predicate = NSPredicate(format: "nextVisit >= %@ && nextVisit <= %@", argumentArray: [start, end])
            
        }
        
        try? patientResultsController?.performFetch()
        updateSnapshot()
    }
    
}

extension PatientListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PatientDetail") as! PatientDetailController
        if let patient = patientResultsController?.object(at: indexPath) {
            controller.setupWith(patient)
        }

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PatientListController: NSFetchedResultsControllerDelegate {
    
    func updateSnapshot() {
        guard let fetchedResultsController = patientResultsController else {return}
        
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Patient>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(diffableDataSourceSnapshot)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if tableView.window != nil {
            updateSnapshot()
        }
    }
}

