import Fluent
import Vapor

enum Sex: String, Codable {
    case male = "M"
    case female = "F"
}

enum EventType: String, Codable {
    case powerlifting = "SBD"
    case benchPress = "B"
}

enum Equipment: String, Codable {
    case raw = "Raw"
    case equipped = "SinglePly"
}
