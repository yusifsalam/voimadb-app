import Foundation
import Hummingbird

struct Competition {
    var id: Int
    var name: String
    var description: String?
    var date: Date
    var city: String
    var country: String
    
}

extension Competition: ResponseEncodable, Decodable, Equatable {}
