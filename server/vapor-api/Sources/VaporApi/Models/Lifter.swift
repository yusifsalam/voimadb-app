import Vapor
import Fluent

final class Lifter: Model, Content, @unchecked Sendable {
    static let schema = "lifters"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @Field(key: "firstname")
    var firstname: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "birthyear")
    var birthyear: Int
    
    @Field(key: "sex")
    var sex: Sex
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "slug")
    var slug: String
    
    @Children(for: \.$lifter)
    var results: [Result]
    
    init() { }
    
    init(id: Int? = nil, firstname: String, lastname: String, birthyear: Int, sex: Sex, slug: String = "slug") {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.birthyear = birthyear
        self.sex = sex
        self.name = "\(firstname) \(lastname)"
        self.slug = slug
    }
}
