import Fluent
import Vapor

final class Result: Model, Content, @unchecked Sendable {
    static let schema = "results"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Parent(key: "competition_id")
    var competition: Competition

    @Parent(key: "lifter_id")
    var lifter: Lifter

    @Field(key: "bodyweight")
    var bodyweight: Double

    @OptionalParent(key: "club_id")
    var club: Club?

    @Field(key: "squat1")
    var squat1: Double

    @Field(key: "squat1success")
    var squat1Success: Bool

    @Field(key: "squat2")
    var squat2: Double

    @Field(key: "squat2success")
    var squat2Success: Bool

    @Field(key: "squat3")
    var squat3: Double

    @Field(key: "squat3success")
    var squat3Success: Bool

    @Field(key: "bestsquat")
    var bestSquat: Double

    @Field(key: "bench1")
    var bench1: Double

    @Field(key: "bench1success")
    var bench1Success: Bool

    @Field(key: "bench2")
    var bench2: Double

    @Field(key: "bench2success")
    var bench2Success: Bool

    @Field(key: "bench3")
    var bench3: Double

    @Field(key: "bench3success")
    var bench3Success: Bool

    @Field(key: "bestbench")
    var bestBench: Double

    @Field(key: "deadlift1")
    var deadlift1: Double

    @Field(key: "deadlift1success")
    var deadlift1Success: Bool

    @Field(key: "deadlift2")
    var deadlift2: Double

    @Field(key: "deadlift2success")
    var deadlift2Success: Bool

    @Field(key: "deadlift3")
    var deadlift3: Double

    @Field(key: "deadlift3success")
    var deadlift3Success: Bool

    @Field(key: "bestdeadlift")
    var bestDeadlift: Double

    @Field(key: "total")
    var total: Double

    @Field(key: "points")
    var points: Double

    @OptionalField(key: "position")
    var position: Int?

    init() {}

    init(id: Int? = nil, competitionID: Competition.IDValue, lifterID: Lifter.IDValue,
         bodyweight: Double, clubID: Club.IDValue? = nil, squat1: Double, squat1Success: Bool,
         squat2: Double, squat2Success: Bool, squat3: Double, squat3Success: Bool, bestSquat: Double,
         bench1: Double, bench1Success: Bool, bench2: Double, bench2Success: Bool, bench3: Double,
         bench3Success: Bool, bestBench: Double, deadlift1: Double, deadlift1Success: Bool,
         deadlift2: Double, deadlift2Success: Bool, deadlift3: Double, deadlift3Success: Bool,
         bestDeadlift: Double, total: Double, points: Double, position: Int? = nil)
    {
        self.id = id
        $competition.id = competitionID
        $lifter.id = lifterID
        self.bodyweight = bodyweight
        $club.id = clubID
        self.squat1 = squat1
        self.squat1Success = squat1Success
        self.squat2 = squat2
        self.squat2Success = squat2Success
        self.squat3 = squat3
        self.squat3Success = squat3Success
        self.bestSquat = bestSquat
        self.bench1 = bench1
        self.bench1Success = bench1Success
        self.bench2 = bench2
        self.bench2Success = bench2Success
        self.bench3 = bench3
        self.bench3Success = bench3Success
        self.bestBench = bestBench
        self.deadlift1 = deadlift1
        self.deadlift1Success = deadlift1Success
        self.deadlift2 = deadlift2
        self.deadlift2Success = deadlift2Success
        self.deadlift3 = deadlift3
        self.deadlift3Success = deadlift3Success
        self.bestDeadlift = bestDeadlift
        self.total = total
        self.points = points
        self.position = position
    }
}
