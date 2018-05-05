//
//  RealmConvertible.swift
//  RealmSupport
//
//  Created by ark dan on 23/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

open class ModelObject: RealmSwift.Object {
    @objc open dynamic var id: String = ""

    open override class func primaryKey() -> String? {
        return "id"
    }

    public required init(id: String) {
        self.id = id
        super.init()
    }

    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super .init(realm: realm, schema: schema)
    }

    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    public required init() {
        super.init()
    }
}

extension ModelObject {

    public func persist(realm: Realm = makeRealm()) {
        let block = {
            _ = realm.create(type(of: self), value: self, update: true)
        }

        if realm.isInWriteTransaction {
            block()
        } else {
            do {
                try realm.write { block() }
            } catch {
                print("errr \(error)")
            }
        }
    }

    public func persistSafe(realm: Realm = makeRealm()) throws {
        let block = {
            _ = realm.create(type(of: self), value: self, update: true)
        }

        if realm.isInWriteTransaction {
            block()
        } else {
            try realm.write { block() }
        }
    }

    public func unpersist(realm: Realm = makeRealm()) {

        // no need to delete if not persisted
        if self.realm == nil {
            return
        }
        let block = {
            if let object = realm.object(ofType: type(of: self), forPrimaryKey: self.id) {
                realm.delete(object)
            }
        }
        if realm.isInWriteTransaction {
            block()
        } else {
            try! realm.write { block() }
        }
        unpersistRelationships()
    }

    public func unpersistSafe(realm: Realm = makeRealm()) throws {

        // no need to delete if not persisted
        if self.realm == nil {
            return
        }
        let block = {
            if let object = realm.object(ofType: type(of: self), forPrimaryKey: self.id) {
                realm.delete(object)
            }
        }
        if realm.isInWriteTransaction {
            block()
        } else {
            try realm.write { block() }
        }
        unpersistRelationships()
    }


    // should be implemented by types with relationships.
    // Workaround until Realm supports cascade delete
    public func unpersistRelationships() {
    }
}

extension ModelObject {
    public static func managedObject(id: String, realm: Realm = makeRealm()) -> Self? {
        return realm.object(ofType: self, forPrimaryKey: id)
    }
}
