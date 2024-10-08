//
//  SyncerStorage.swift
//
//  Created by Sun on 2024/6/13.
//

import Foundation

import GRDB

// MARK: - SyncerStorage

class SyncerStorage {
    // MARK: Properties

    private let dbPool: DatabasePool

    // MARK: Computed Properties

    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("create Initial Sync Completed") { db in
            try db.create(table: InitialSyncCompleted.databaseTableName) { t in
                t.column(InitialSyncCompleted.Columns.api.name, .text)
                t.column(InitialSyncCompleted.Columns.id.name, .text)
                t.column(InitialSyncCompleted.Columns.completed.name, .boolean).notNull()
                
                t.primaryKey(
                    [InitialSyncCompleted.Columns.api.name, InitialSyncCompleted.Columns.id.name],
                    onConflict: .replace
                )
            }
        }

        return migrator
    }

    // MARK: Lifecycle

    init(databaseDirectoryURL: URL, databaseFileName: String) {
        let databaseURL = databaseDirectoryURL.appendingPathComponent("\(databaseFileName).sqlite")

        dbPool = try! DatabasePool(path: databaseURL.path)

        try! migrator.migrate(dbPool)
    }
}

extension SyncerStorage {
    func initialSyncCompleted(api: String) -> Bool? {
        try? dbPool.read { db in
            try InitialSyncCompleted.filter(InitialSyncCompleted.Columns.api == api).fetchOne(db)?.completed
        }
    }

    func save(api: String, id: String, initialSyncCompleted: Bool) {
        _ = try! dbPool.write { db in
            let record = InitialSyncCompleted(api: api, id: id, completed: initialSyncCompleted)
            try record.insert(db)
        }
    }
}
