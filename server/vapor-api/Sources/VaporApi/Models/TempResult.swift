import Vapor
import Fluent

final class TempResult: Model, Content, @unchecked Sendable {
    static let schema = "temp_results"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @OptionalField(key: "temp_id")
    var tempId: Int?
    
    @OptionalField(key: "competitionid")
    var competitionId: Int?
    
    @OptionalField(key: "competitionname")
    var competitionName: String?
    
    @OptionalField(key: "competitiondate")
    var competitionDate: String?
    
    @OptionalField(key: "competitionlocation")
    var competitionLocation: String?
    
    @OptionalField(key: "name")
    var name: String?
    
    @OptionalField(key: "birthyear")
    var birthyear: Int?
    
    @OptionalField(key: "gender")
    var gender: String?
    
    @OptionalField(key: "weightclass")
    var weightClass: Int?
    
    @OptionalField(key: "bodyweight")
    var bodyweight: Double?
    
    @OptionalField(key: "club")
    var club: String?
    
    @OptionalField(key: "squat1")
    var squat1: Double?
    
    @OptionalField(key: "squat1success")
    var squat1Success: String?
    
    @OptionalField(key: "squat2")
    var squat2: Double?
    
    @OptionalField(key: "squat2success")
    var squat2Success: String?
    
    @OptionalField(key: "squat3")
    var squat3: Double?
    
    @OptionalField(key: "squat3success")
    var squat3Success: String?
    
    @OptionalField(key: "bestsquat")
    var bestSquat: Double?
    
    @OptionalField(key: "bench1")
    var bench1: Double?
    
    @OptionalField(key: "bench1success")
    var bench1Success: String?
    
    @OptionalField(key: "bench2")
    var bench2: Double?
    
    @OptionalField(key: "bench2success")
    var bench2Success: String?
    
    @OptionalField(key: "bench3")
    var bench3: Double?
    
    @OptionalField(key: "bench3success")
    var bench3Success: String?
    
    @OptionalField(key: "bestbench")
    var bestBench: Double?
    
    @OptionalField(key: "deadlift1")
    var deadlift1: Double?
    
    @OptionalField(key: "deadlift1success")
    var deadlift1Success: String?
    
    @OptionalField(key: "deadlift2")
    var deadlift2: Double?
    
    @OptionalField(key: "deadlift2success")
    var deadlift2Success: String?
    
    @OptionalField(key: "deadlift3")
    var deadlift3: Double?
    
    @OptionalField(key: "deadlift3success")
    var deadlift3Success: String?
    
    @OptionalField(key: "bestdeadlift")
    var bestDeadlift: Double?
    
    @OptionalField(key: "total")
    var total: Double?
    
    @OptionalField(key: "points")
    var points: Double?
    
    @OptionalField(key: "position")
    var position: Int?
    
    init() { }
}
