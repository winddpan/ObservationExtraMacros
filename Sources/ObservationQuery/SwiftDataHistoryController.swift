//
//  SwiftDataHistoryController.swift
//  ObservationExtraMacros
//
//  Created by winddpan on 2024/11/25.
//

import Combine
import CoreData
import Foundation
import SwiftData

class SwiftDataHistoryController {
    static let shared = SwiftDataHistoryController()

    private var tokenManager = PersistentHistoryTokenManager()
    private var managedObjectContext: NSManagedObjectContext!
    let modelChanges = PassthroughSubject<Set<String>, Never>()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(objectsChanged),
            name: .NSPersistentStoreRemoteChange,
            object: nil)
    }

    @MainActor @objc private func objectsChanged(_ notification: Notification) {
        guard let coordinator = notification.object as? NSPersistentStoreCoordinator else { return }

        let fetchRequest: NSPersistentHistoryChangeRequest
        if let lastToken = tokenManager.lastToken() {
            fetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)
        } else {
            fetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: Date().addingTimeInterval(-1))
        }

        if managedObjectContext?.persistentStoreCoordinator !== coordinator {
            self.managedObjectContext = NSManagedObjectContext(
                concurrencyType: .mainQueueConcurrencyType
            )
            managedObjectContext.persistentStoreCoordinator = coordinator
        }

        do {
            var updateModels = Set<String>()
            let result = try managedObjectContext.execute(fetchRequest) as? NSPersistentHistoryResult
            if let transactions = result?.result as? [NSPersistentHistoryTransaction] {
                for transaction in transactions {
                    for change in transaction.changes ?? [] {
                        if let entityName = change.changedObjectID.entity.name {
                            updateModels.insert(entityName)
                        }
                    }
                }
                if let lastToken = transactions.last?.token {
                    tokenManager.saveToken(lastToken)
                }
                if !updateModels.isEmpty {
                    self.modelChanges.send(updateModels)
                }
            }
        } catch {
            print("Error fetching change history: \(error)")
        }
    }
}

private class PersistentHistoryTokenManager {
    private let tokenKey = "PersistentHistoryToken"
    private var _lastToken: NSPersistentHistoryToken?

    // Save token to UserDefaults
    func saveToken(_ token: NSPersistentHistoryToken) {
        guard
            let data = try? NSKeyedArchiver.archivedData(
                withRootObject: token,
                requiringSecureCoding: true)
        else { return }
        UserDefaults.standard.set(data, forKey: tokenKey)
        _lastToken = token
    }

    // Retrieve last token
    func lastToken() -> NSPersistentHistoryToken? {
        if let _lastToken { return _lastToken }
        guard let tokenData = UserDefaults.standard.data(forKey: tokenKey),
            let token = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSPersistentHistoryToken.self,
                from: tokenData)
        else { return nil }
        _lastToken = token
        return token
    }
}
