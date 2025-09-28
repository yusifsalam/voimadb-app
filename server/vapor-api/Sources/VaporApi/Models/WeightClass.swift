import Vapor
import Fluent

final class WeightClass: Model, Content, @unchecked Sendable {
    static let schema = "weight_class"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "sex")
    var sex: Sex
    
    @Field(key: "lowerBound")
    var lowerBound: Double
    
    @Field(key: "upperBound")
    var upperBound: Double
    
    @Field(key: "validFrom")
    var validFrom: Date
    
    @OptionalField(key: "validUntil")
    var validUntil: Date?
    
   
    
    init() { }
    
    init(id: Int? = nil, name: String = "", sex: Sex, lowerBound: Double, upperBound: Double, 
         validFrom: Date, validUntil: Date? = nil) {
        self.id = id
        self.name = name
        self.sex = sex
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
