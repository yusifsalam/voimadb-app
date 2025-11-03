import Fluent
import Vapor

final class Club: Model, Content, @unchecked Sendable {
    static let schema = "clubs"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "shortname")
    var shortname: String

    @OptionalField(key: "municipality")
    var municipality: String?

    @OptionalField(key: "website")
    var website: String?

    @Field(key: "active")
    var active: Bool

    @Children(for: \.$club)
    var results: [Result]

    init() {}

    init(id: Int? = nil, name: String, shortname: String, municipality: String? = nil, website: String? = nil, active: Bool = false) {
        self.id = id
        self.name = name
        self.shortname = shortname
        self.municipality = municipality
        self.website = website
        self.active = active
    }
}
