//
//  Alamofire+Error+MoveToOEXFound.swift
//  Core
//
//  Created by Anton Yarmolenka on 11/02/2025.
//

import Foundation

// ToDo: Move to OEXFoundation
public extension Error {
    var errorCode: Int {
        guard let afError = self.asAFError else {
            return (self as NSError).code
        }
        
        if let validationError = afError.validationError {
            return validationError.statusCode
        }
        
        if let code = afError.responseCode {
            return code
        }
        
        return (self as NSError).code
    }
    
    var errorMessage: String {
        guard let afError = self.asAFError else {
            return (self as NSError).localizedDescription
        }
        
        if let validationError = afError.validationError,
           let data = validationError.data,
        let error = data["error"] as? String {
            return error
        }
        
        return afError.localizedDescription
    }
}
