import Foundation
import SwiftData

@Model
final class TaskResponse {
    var id: UUID = UUID()
    var taskID: String = ""
    // For decision: 1 element. For multi_select_grouped: 0..N elements.
    var selectedOptionIDs: [String] = []
    var answeredAt: Date = Date()
    var profile: TripProfile?

    var singleAnswer: String? { selectedOptionIDs.first }

    init(taskID: String, selectedOptionIDs: [String]) {
        self.taskID = taskID
        self.selectedOptionIDs = selectedOptionIDs
        self.answeredAt = Date()
    }
}
