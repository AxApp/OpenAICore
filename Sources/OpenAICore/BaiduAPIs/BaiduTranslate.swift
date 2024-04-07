//
//  File.swift
//  
//
//  Created by linhey on 2024/4/7.
//

import Foundation
import Crypto

//https://fanyi-api.baidu.com/api/trans/vip/translate

public struct BaiduTranslate {
        
    public struct SignParameter: Codable {
        public let sign: String
        public let salt: String
        public let appid: String
        public static var salt: String { (1000000000..<10000000000).randomElement()?.description ?? "salt" }
        
        var toQueries: [String: String] {
            var dict = [String: String]()
            dict["sign"] = sign
            dict["appid"] = appid
            dict["salt"] = salt
            return dict
        }
    }
    
    public struct TranslateParameter: Codable {
       
        public var q: String
        public var from: HumanLangeuage
        public var to: HumanLangeuage
        /// 判断是否需要使用自定义术语干预API, 1-是，0-否
        public var action: Bool?
        
        public init(q: String, from: HumanLangeuage, to: HumanLangeuage, action: Bool? = nil) {
            self.q = q
            self.from = from
            self.to = to
            self.action = action
        }
        
        var toQueries: [String: String] {
            var dict = [String: String]()
            dict["q"] = q
            dict["from"] = from.rawValue
            dict["to"] = to.rawValue
            dict["action"] = action.flatMap({ $0 ? "1" : "0" })
            return dict
        }

        public func sign(_ service: BaiduTranslateService) -> [String: String] {
            let sign = signParameter(service)
            return self.toQueries.merging(sign.toQueries, uniquingKeysWith: { $1 })
        }
        
        public func signParameter(_ service: BaiduTranslateService) -> SignParameter {
            let salt = SignParameter.salt
            guard let data = (service.appID
                              + q
                              + salt
                              + service.appKey).data(using: .utf8) else {
                return .init(sign: "", salt: "", appid: service.appID)
            }
            let sign = Insecure.MD5.hash(data: data).map {
                String(format: "%02hhx", $0)
            }.joined()
            return SignParameter.init(sign: sign, salt: salt, appid: service.appID)
        }
        
    }
    
}

public extension BaiduTranslate {
    
    struct ErrorResponse: Codable, LocalizedError {
        public let error_code: String
        public let error_msg: String
    }

    struct TranslateResult: Codable {
        public let src: String
        public let dst: String
    }
    
    struct TranslateResponse: Codable {
        public let from: String
        public let to: String
        public let trans_result: [TranslateResult]
    }
    
}
