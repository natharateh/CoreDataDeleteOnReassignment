import Foundation
import CoreData

class ModelController: NSObject {

    override init() {
        super.init()
        clearAll()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDeleteOnReassignment")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func createNewPeopleAndAssignToGroup(peopleNames: [String], groupName: String) {
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: persistentContainer.viewContext) as! Group
        group.name = groupName
        for personName in peopleNames {
            let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: persistentContainer.viewContext) as! Person
            person.name = personName
            person.group = group
        }
        saveContext()
    }

    func replaceAllPeople(in group: Group, withPeopleWithNames peopleNames: [String]) {
        var newPeople = Set<Person>()
        for name in peopleNames {
            let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: persistentContainer.viewContext) as! Person
            person.name = name
            newPeople.insert(person)
        }
        group.people = newPeople
        saveContext()
    }

    func clearAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Group")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? persistentContainer.viewContext.execute(batchDeleteRequest)
    }

    private func allGroups() -> [Group]? {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        return try? persistentContainer.viewContext.fetch(fetchRequest)
    }
}
