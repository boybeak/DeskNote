//
//  NoteManager.swift
//  DeskNote
//
//  Created by Beak on 2024/6/12.
//

import CoreData

class NoteManager {
    
    static let shared = NoteManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DeskNote")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private init() {}
    
    // Create
    func addNote(position: CGPoint)-> Note {
        let context = persistentContainer.viewContext
        let note = Note(context: context, position: position)
        
        context.insert(note)
        saveContext()
        
        return note
    }
    
    // Read
    func fetchAllNotes() -> [Note] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            let notes = try context.fetch(fetchRequest)
            return notes
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }
    
    // Update
    func updateNote() {
        saveContext()
    }
    
    // Delete
    func deleteNote(note: Note) {
        let context = persistentContainer.viewContext
        context.delete(note)
        saveContext()
    }
    
    // Save context
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
