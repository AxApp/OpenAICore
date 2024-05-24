//
//  File.swift
//  
//
//  Created by linhey on 2023/8/31.
//

import Foundation
import HTTPTypes

struct OAIFineTuning: Codable, Identifiable {
    
    enum Status: String, Codable {
        case validating_files
        case queued
        case running
        case succeeded
        case failed
        case cancelled
    }
    
    enum Object: String, Codable {
        case fine_tuning_job = "fine_tuning.job"
    }
    
    enum Model: String, Codable {
        case gpt_35_turbo_0613 = "gpt-3.5-turbo-0613"
        case babbage_002
        case davinci_002
    }
    
    struct Hyperparameters: Codable {
        let n_epochs: String
    }
    
    /// Fine-tuning job的唯一标识符，可在API端点中引用。
    let id: String
    
    /// 对象类型，始终为 "fine_tuning.job"。
    let object: Object
    
    /// Fine-tuning job创建的Unix时间戳（以秒为单位）。
    let created_at: Int
    
    /// Fine-tuning job完成的Unix时间戳（以秒为单位）。如果Fine-tuning job仍在运行，该值将为null。
    let finished_at: Int?
    
    /// 正在进行微调的基础模型。
    let model: Model
    
    /// 正在创建的微调模型的名称。如果Fine-tuning job仍在运行，该值将为null。
    let fine_tuned_model: String?
    
    /// 拥有Fine-tuning job的组织的标识符。
    let organization_id: String
    
    /// Fine-tuning job的当前状态，可以是 "validating_files", "queued", "running", "succeeded", "failed", 或 "cancelled" 中的一个。
    let status: Status
    
    /// 用于Fine-tuning job的超参数。可以根据需要为超参数指定更具体的类型。
    let hyperparameters: Hyperparameters?
    
    /// 用于训练的文件ID。可以使用Files API检索训练数据。
    let training_file: OAIFile.Response.ID
    
    /// 用于验证的文件ID。可以使用Files API检索验证结果。如果为null，表示没有验证文件。
    let validation_file: OAIFile.Response.ID?
    
    /// Fine-tuning job的编译结果文件ID。可以使用Files API检索结果。
    let result_files: [OAIFile.Response.ID]
    
    /// 由该Fine-tuning job处理的总计费令牌数。如果Fine-tuning job仍在运行，该值将为null。
    let trained_tokens: Int?
    
    /// 对于失败的Fine-tuning job，此字段将包含有关失败原因的更多信息。如果Fine-tuning job成功或正在运行，该值将为null。
    // let error: [String: Any]?
}

struct OAIPager {
    let after: String? = nil
    let limit: Int? = nil
    
    func apply(client: LLMClientProtocol, request: HTTPRequest) -> HTTPRequest {
        var request = request
        if let after = after {
            request = client.add(queries: ["after": after], to: request)
        }
        if let limit = limit {
            request = client.add(queries: ["limit": "\(limit)"], to: request)
        }
        return request
    }
}

struct OAIFineTuningAPIs {
    
    public let client: LLMClientProtocol
    public let serivce: OAISerivce
    
    public init(client: LLMClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    struct CreateRequest: Codable {
        let training_file: OAIFile.Response.ID
        let validation_file: OAIFile.Response.ID?
        let model: OAIFineTuning.Model
        let hyperparameters: OAIFineTuning.Hyperparameters?
        let suffix: String?
    }
    
    /// Create a fine-tuning job.
    /// POST https://api.openai.com/v1/fine_tuning/jobs
    func create(_ parameters: CreateRequest) async throws -> OAIFineTuning {
        var request = client.request(of: serivce, path: "v1/fine_tuning/jobs")
        request.method = .post
        let request_body = try client.encoder.encode(parameters)
        let response = try await client.upload(for: request, from: request_body)
        return try client.decode(response)
    }
    
    
    /// List fine-tuning jobs.
    /// GET https://api.openai.com/v1/fine_tuning/jobs
    func list(pager: OAIPager? = nil) async throws -> [OAIFineTuning] {
        var request = client.request(of: serivce, path: "v1/fine_tuning/jobs")
        if let pager {
            request = pager.apply(client: client, request: request)
        }
        let data = try await client.data(for: request)
        return try client.decode(OAIDataResponse<[OAIFineTuning]>.self, from: data).data
    }
    
    /// Get info about a fine-tuning job.
    /// GET https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}
    func retrieve(id: OAIFineTuning.ID) async throws -> OAIFineTuning {
        let request = client.request(of: serivce, path: "v1/fine_tuning/jobs/\(id)")
        let data = try await client.data(for: request)
        return try client.decode(data)
    }
    
    /// Get info about a fine-tuning job.
    /// POST https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel
    func cancel(id: OAIFineTuning.ID) async throws -> OAIFineTuning {
        var request = client.request(of: serivce, path: "v1/fine_tuning/jobs/\(id)/cancel")
        request.method = .post
        let data = try await client.data(for: request)
        return try client.decode(data)
    }
    
    
    
    /// Get info about a fine-tuning job.
    /// POST https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel
    func events(id: OAIFineTuning.ID, pager: OAIPager? = nil) async throws -> [OAIFineTuning] {
        var request = client.request(of: serivce, path: "v1/fine_tuning/jobs/\(id)/events")
        request.method = .post
        if let pager {
            request = pager.apply(client: client, request: request)
        }
        let data = try await client.data(for: request)
        return try client.decode(OAIDataResponse<[OAIFineTuning]>.self, from: data).data
    }
}
