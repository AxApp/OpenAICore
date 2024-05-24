//
//  File.swift
//
//
//  Created by linhey on 2023/5/19.
//

import Foundation
import Combine
import OpenAICore
import HTTPTypes
import HTTPTypesFoundation
import Alamofire

public class OAIClient: LLMClientProtocol {
    
    public static let shared = OAIClient()
    
    private var cancellables = Set<AnyCancellable>()
    
    public func data(for request: HTTPRequest) async throws -> LLMResponse {
        let response = try await URLSession.shared.data(for: request)
        return .init(data: response.0, response: response.1)
    }
    
    public func upload(for request: HTTPRequest, from file: UploadFileFormData) async throws -> LLMResponse {
        let response = AF.upload(multipartFormData: { form in
            form.append("file-extract".data(using: .utf8)!, withName: "purpose")
            if let fileName = file.fileName, let mimeType = file.mimeType {
                form.append(file.fileURL,
                            withName: file.name,
                            fileName: fileName,
                            mimeType: mimeType)
            } else {
                form.append(file.fileURL, withName: file.name)
            }
        }, with: URLRequest(httpRequest: request)!)
        .serializingData()
        return try await .init(data: response.value,
                               response: response.response.response!.httpResponse!)
    }
    
    public func upload(for request: HTTPRequest, from bodyData: Data) async throws -> LLMResponse {
        let response = try await URLSession.shared.upload(for: request, from: bodyData)
        return .init(data: response.0, response: response.1)
    }
    
    public func serverSendEvent(for request: HTTPTypes.HTTPRequest, 
                                from bodyData: Data,
                                failure: (OpenAICore.LLMResponse) async throws -> Void) async throws -> AsyncThrowingStream<Data, any Error> {
        .makeStream().stream
    }
}
