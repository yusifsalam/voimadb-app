import Vapor
import Fluent

final class Competition: Model, Content, @unchecked Sendable {
    static let schema = "competitions"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "date")
    var date: Date
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "event_type")
    var eventType: EventType
    
    @Field(key: "equipment")
    var equipment: Equipment
    
    
    @Field(key: "city")
    var city: String
    
    @Field(key: "country")
    var country: String
    
    @Children(for: \.$competition)
    var results: [Result]
    
    init() { }
    
    init(id: Int? = nil, name: String, date: Date, description: String? = nil,
         eventType: EventType, equipment: Equipment, city: String, country: String) {
        self.id = id
        self.name = name
        self.date = date
        self.description = description
        self.eventType = eventType
        self.equipment = equipment
        self.city = city
        self.country = country
    }
}
