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
        
        let fetchRequest = NSFetchRequest<EntityA>(entityName: EntityA.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "attributeA", ascending: true)];
        let result = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        result.delegate = self
        do {
            try result.performFetch()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
        return result
    }()
    
    //Initialized in viewDidLoad - treat it like an IBOutlet
    var diffableDataSource: UITableViewDiffableDataSource<Int, EntityA>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addEntities()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifier")
        diffableDataSource = UITableViewDiffableDataSource<Int, EntityA>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
               let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
            cell.textLabel?.text = item.attributeA
               return cell
           }
           
        let _ = fetchedResultsController
    }
    
    func addEntities() {
        
        guard let application = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let mainThreadContext = application.persistentContainer.viewContext
        
        mainThreadContext.perform {
            //Crash on config error, thus try!
            let entityDescription = try! EntityA.entityDescription(in: mainThreadContext)
            
            if let entityA = NSManagedObject(entity: entityDescription, insertInto: mainThreadContext) as? EntityA {
                entityA.attributeA = "Entity A"
                
            } else {
                fatalError("Unable to create an EntityA")
            }
            do {
                try mainThreadContext.save()
            } catch {
                print(error.localizedDescription)
            }
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

