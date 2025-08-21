//
//  EnrollmentEndpoint.swift
//  Core
//
//  Created by Shafqat Muneer on 7/28/25.
//

import Foundation
import Alamofire

enum EnrollmentEndpoint: EndPointType {
    case getEnrollmentDetails(courseID: String)
    
    var path: String {
        switch self {
        case .getEnrollmentDetails(let courseID):
            return "/api/mobile/v1/course_info/\(courseID)/enrollment_details"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getEnrollmentDetails:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var task: HTTPTask {
        switch self {
        case .getEnrollmentDetails:
            return .requestParameters(encoding: JSONEncoding.default)
        }
    }
}
