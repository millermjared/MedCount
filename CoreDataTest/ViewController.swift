//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//

import UIKit
import CoreData


class ViewController: UITableViewController {

    lazy var fetchedResultsController: NSFetchedResultsController<EntityA>? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let container = appDelegate.persistentContainer
                
        do {
            let result = try EntityA.fetchedResultsController(in: container.viewContext, sortedBy: [("attributeA", true)])
                        
            result.delegate = self
            
            try result.performFetch()
            
            return result
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
        return nil
    }()
    
    //Initialized in viewDidLoad - treat it like an IBOutlet
    var diffableDataSource: UITableViewDiffableDataSource<Int, EntityA>!
    
    override func viewDidLoad() {
            //addEntities()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifier")
        diffableDataSource = UITableViewDiffableDataSource<Int, EntityA>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
               let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
            cell.textLabel?.text = item.attributeA
               return cell
           }
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? self.fetchedResultsController?.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateSnapshot()
    }
    
    func addEntities() {
        
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        if let newEntity = try? EntityA.new(mainThreadContext) {
            newEntity.attributeA = "created using convenience method"
        }
        do {
            try mainThreadContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func updateSnapshot() {
        guard let fetchedResultsController = fetchedResultsController else {return}
        
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, EntityA>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(diffableDataSourceSnapshot)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

