import UIKit
import CoreData

class ViewController: UIViewController {
    private let reuseIdentifier = "UITableViewCell"
    @IBOutlet private weak var tableView: UITableView!

    private let modelController = ModelController()

    private lazy var fetchedResultsController: NSFetchedResultsController<Person> = {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let groupNameSortDescriptor = NSSortDescriptor(keyPath: \Group.name, ascending: true)
        let personNameSortDescriptor = NSSortDescriptor(keyPath: \Person.name, ascending: true)
        fetchRequest.sortDescriptors = [groupNameSortDescriptor, personNameSortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: modelController.persistentContainer.viewContext, sectionNameKeyPath: "group.name", cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tableView.backgroundColor
        modelController.createNewPeopleAndAssignToGroup(peopleNames: ["Abby", "John", "Zuri", "Joanna", "Michael", "Jack", "Laura"], groupName: "Students")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].objects?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let person = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.row] as? Person else {
            return cell
        }
        cell.textLabel?.text = person.name
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = fetchedResultsController.sections?[section] else {
            return nil
        }
        let headerView = TableViewSectionHeaderView.instanceFromNib()
        headerView.configure(with: section.name, deleteAction: {
            // unused for now
        }, replaceAction: { [weak self] in
            guard let self = self else {
                return
            }
            guard let group = (section.objects?.first as? Person)?.group else {
                return
            }
            self.modelController.replaceAllPeople(in: group, withPeopleWithNames: ["Tom", "Jerry"])
        })
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // After tapping on "Replace" and triggering replaceAllPeople in ModelController
        // Break here and inspect fetchedResultsController.sections
        // There will be 2 sections instead of 1
        // po fetchedResultsController.sections![0].objects - this is the original section but the group is now nil
        // po fetchedResultsController.sections![1].objects - this is the new section with the existing group assigned
        assert(fetchedResultsController.sections?.count == 1)
    }
}

