import Foundation

struct CalculationResult: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let inputs: String
    let result: String
    let date: Date
    
    init(id: UUID = UUID(), name: String, type: String, inputs: String, result: String, date: Date = Date()) {
        self.id = id
        self.name = name
        self.type = type
        self.inputs = inputs
        self.result = result
        self.date = date
    }
}

