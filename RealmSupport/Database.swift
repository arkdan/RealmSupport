//
//  Database.swift
//  RealmSupport
//
//  Created by mac on 8/21/17.
//  Copyright © 2017 Arkadi Daniyelian. All rights reserved.
//

import Foundation
import RealmSwift


public extension Realm {

    public static func migrate(version: UInt64 = 1) {
        Configuration.defaultConfiguration.schemaVersion = version
    }
}

public var makeRealm: () -> Realm = {
    return try! Realm()
}

extension Realm {
    public func clear<T: RealmSwift.Object>(types: [T.Type]) {
        types.forEach { type in
            try! write {
                delete(objects(type.self))
            }
        }
    }

    public func delete<ObjectType: ModelObject>(type: ObjectType.Type, ids: [String]) {
        let block = {
            ids.forEach { id in
                if let object = self.object(ofType: type, forPrimaryKey: id) {
                    self.delete(object)
                }
            }
        }
        if isInWriteTransaction {
            block()
        } else {
            try! write { block() }
        }
    }

    public func deleteSafe<ObjectType: ModelObject>(type: ObjectType.Type, ids: [String]) throws {
        let block = {
            ids.forEach { id in
                if let object = self.object(ofType: type, forPrimaryKey: id) {
                    self.delete(object)
                }
            }
        }
        if isInWriteTransaction {
            block()
        } else {
            try write { block() }
        }
    }
}

extension RealmSwift.Object {

    public var isStored: Bool {
        return self.realm != nil
    }
}
