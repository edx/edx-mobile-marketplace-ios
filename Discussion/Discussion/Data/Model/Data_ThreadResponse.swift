//
//  ThreadResponse.swift
//  Discussion
//
//  Created by  Stepanok Ivan on 17.11.2022.
//

import Foundation
import Core

public extension DataLayer {
    // MARK: - ThreadLists
    struct ThreadListsResponse: Codable {
        public let threads: [ThreadList]
        public let textSearchRewrite: String?
        public let pagination: Pagination
        
        enum CodingKeys: String, CodingKey {
            case threads = "results"
            case textSearchRewrite = "text_search_rewrite"
            case pagination = "pagination"
        }
        
        public init(threads: [ThreadList], textSearchRewrite: String?, pagination: Pagination) {
            self.threads = threads
            self.textSearchRewrite = textSearchRewrite
            self.pagination = pagination
        }
    }
 
    // MARK: - Thread
    struct ThreadList: Codable {
        public let id: String
        public let author: String?
        public let authorLabel: String?
        public let createdAt: String
        public let updatedAt: String
        public let rawBody: String
        public let renderedBody: String
        public let abuseFlagged: Bool
        public let voted: Bool
        public let voteCount: Int
        public let courseID: String
        public let topicID: String
        public let type: PostType
        public let title: String
        public let pinned: Bool
        public let closed: Bool
        public let following: Bool
        public let commentCount: Int
        public let unreadCommentCount: Int
        public let read: Bool
        public let hasEndorsed: Bool
        public let users: Users?
        
        enum CodingKeys: String, CodingKey {
            case id
            case author
            case authorLabel = "author_label"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case rawBody = "raw_body"
            case renderedBody = "rendered_body"
            case abuseFlagged = "abuse_flagged"
            case voted
            case voteCount = "vote_count"
            case courseID = "course_id"
            case topicID = "topic_id"
            case type
            case title
            case pinned
            case closed
            case following
            case commentCount = "comment_count"
            case unreadCommentCount = "unread_comment_count"
            case read
            case hasEndorsed = "has_endorsed"
            case users
        }
        
        public init(from decoder: Decoder) throws {
                  let container = try decoder.container(keyedBy: CodingKeys.self)
                  id = try container.decode(String.self, forKey: .id)
                  author = try container.decodeIfPresent(String.self, forKey: .author)
                  authorLabel = try container.decodeIfPresent(String.self, forKey: .authorLabel)
                  createdAt = try container.decode(String.self, forKey: .createdAt)
                  updatedAt = try container.decode(String.self, forKey: .updatedAt)
                  rawBody = try container.decode(String.self, forKey: .rawBody)
                  renderedBody = try container.decode(String.self, forKey: .renderedBody)
                  abuseFlagged = try container.decode(Bool.self, forKey: .abuseFlagged)
                  voted = try container.decode(Bool.self, forKey: .voted)
                  voteCount = try container.decode(Int.self, forKey: .voteCount)
                  courseID = try container.decode(String.self, forKey: .courseID)
                  topicID = try container.decode(String.self, forKey: .topicID)
                  type = try container.decode(PostType.self, forKey: .type)
                  title = try container.decode(String.self, forKey: .title)
                  pinned = try container.decode(Bool.self, forKey: .pinned)
                  closed = try container.decode(Bool.self, forKey: .closed)
                  following = try container.decode(Bool.self, forKey: .following)
                  commentCount = try container.decode(Int.self, forKey: .commentCount)
                  unreadCommentCount = try container.decodeIfPresent(Int.self, forKey: .unreadCommentCount) ?? 0
                  read = try container.decodeIfPresent(Bool.self, forKey: .read) ?? false
                  hasEndorsed = try container.decode(Bool.self, forKey: .hasEndorsed)
                  users = try container.decodeIfPresent(Users.self, forKey: .users)
              }
    }
    
    // MARK: - Users
    struct Users: Codable {
        public let userName: UserName?
    }

    // MARK: - UserName
    struct UserName: Codable {
        public let profile: Profile?
    }

    // MARK: - Profile
    struct Profile: Codable {
        public let image: AvatarImage?
    }

    // MARK: - Image
    struct AvatarImage: Codable {
        public let hasImage: Bool?
        public let imageURLFull: String?
        public let imageURLLarge: String?
        public let imageURLMedium: String?
        public let imageURLSmall: String?
        
        enum CodingKeys: String, CodingKey {
            case hasImage = "has_image"
            case imageURLFull = "image_url_full"
            case imageURLLarge = "image_url_large"
            case imageURLMedium = "image_url_medium"
            case imageURLSmall = "image_url_small"
        }
    }
}
