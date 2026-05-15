import Foundation
import SwiftData

@Model
final class Child {
    var id: UUID = UUID()
    var age: Int = 5
    var profile: TripProfile?

    init(age: Int) {
        self.age = age
    }
}
