import Foundation

struct Project: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createdAt = "created_at"
    }
}
struct ProjectCreate: Codable {
    let title: String
    let description: String?
    let user_id: Int
}

struct ProjectUpdate: Codable {
    let title: String
    let description: String?
}
