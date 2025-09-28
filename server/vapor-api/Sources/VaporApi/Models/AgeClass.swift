import Vapor
import Fluent

final class AgeClass: Model, Content, @unchecked Sendable {
    static let schema = "age_class"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @Field(key: "sex")
    var sex: Sex
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lowerBound")
    var lowerBound: Int
    
    @Field(key: "upperBound")
    var upperBound: Int
    
    init() { }
    
    init(id: Int? = nil, sex: Sex, name: String, lowerBound: Int, upperBound: Int) {
        self.id = id
        self.sex = sex
        self.name = name
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
}
