//
//  HistoryStoreTests.swift
//  NotInMyBreakfastTests
//
//  Created by Ishraq Mahid on 12/14/25.
//

import Foundation
import XCTest
import CoreData
@testable import NotInMyBreakfast

final class HistoryStoreTests: XCTestCase {
    private var persistence: PersistenceController!
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
    }

    override func tearDown() {
        context = nil
        persistence = nil
        super.tearDown()
    }

    func testAddScanPersistsItem() {
        let store = HistoryStore(context: context, persistenceController: persistence)
        XCTAssertEqual(store.items.count, 0)

        store.addScan(
            barcode: "12345",
            productName: "Granola",
            hadBlacklistedIngredients: true,
            blacklistedIngredients: ["Sugar"]
        )

        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.items.first?.productName, "Granola")
        XCTAssertEqual(store.items.first?.blacklistedIngredients, ["Sugar"])

        // Reload to ensure Core Data persistence in memory works
        let reloaded = HistoryStore(context: context, persistenceController: persistence)
        XCTAssertEqual(reloaded.items.count, 1)
        XCTAssertEqual(reloaded.items.first?.barcode, "12345")
    }

    func testRemoveAllClearsHistory() {
        let store = HistoryStore(context: context, persistenceController: persistence)
        store.addScan(barcode: "1", productName: "Item1", hadBlacklistedIngredients: false)
        store.addScan(barcode: "2", productName: "Item2", hadBlacklistedIngredients: true)
        XCTAssertEqual(store.items.count, 2)

        store.removeAll()
        XCTAssertTrue(store.items.isEmpty)

        let fetch = HistoryEntity.fetchRequest()
        let count = (try? context.count(for: fetch)) ?? -1
        XCTAssertEqual(count, 0)
    }
}
