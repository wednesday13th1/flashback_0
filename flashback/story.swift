//
//  story.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/02/05.
//

import Foundation
import RealmSwift
import UIKit

class Story: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var text: String
    @Persisted var type: String // "photo" or "event"
    @Persisted var imageData: Data?
}
class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()

    func saveStory(image: UIImage?, text: String, type: String) {
        let story = Story()
        story.text = text
        story.type = type

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            story.imageData = imageData
        }

        try! realm.write {
            realm.add(story)
        }
    }

    func fetchStories() -> Results<Story> {
        return realm.objects(Story.self)
    }
}

