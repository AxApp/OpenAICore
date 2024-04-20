//
//  File.swift
//
//
//  Created by linhey on 2023/9/28.
//

import Foundation


public struct OAIAudioAPIs {
    
    public let client: LLMClientProtocol
    public let serivce: OAISerivce
    
    public init(client: LLMClientProtocol, serivce: OAISerivce) {
        self.client = client
        self.serivce = serivce
    }
    
    public enum Model: String, Codable {
        case whisper_1 = "whisper-1"
    }
    
    public enum ResponseFormat: String, Codable {
        case json, text, srt, verbose_json, vtt
    }
    
    public struct TranscriptionsParameter: Codable {
        // Required: The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
        public var file: String
        
        // Required: ID of the model to use. Only whisper-1 is currently available.
        public var model: Model
        
        // Optional: An optional text to guide the model's style or continue a previous audio segment. The prompt should match the audio language.
        public var prompt: String?
        
        // Optional: Defaults to json. The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
        public var response_format: ResponseFormat
        
        // Optional: Defaults to 0. The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use log probability to automatically increase the temperature until certain thresholds are hit.
        public var temperature: Double?
        
        // Optional: The language of the input audio. Supplying the input language in ISO-639-1 format will improve accuracy and latency.
        public var language: String?
        
        public init(file: String,
                    model: Model = .whisper_1,
                    prompt: String? = nil,
                    response_format: ResponseFormat = .json,
                    temperature: Double? = nil,
                    language: String? = nil) {
            self.file = file
            self.model = model
            self.prompt = prompt
            self.response_format = response_format
            self.temperature = temperature
            self.language = language
        }
    }
    
    public struct Transcription: Codable {
        public let text: String
    }
    
    public func transcriptions(_ parameter: TranscriptionsParameter, data: Data) async throws -> Transcription {
        var request = client.request(of: serivce, path: "v1/audio/transcriptions")
        request.method = .post
        request.headerFields[.contentType] = "multipart/form-data; boundary=\(UUID().uuidString)"
        let data = try await client.upload(for: request, from: data)
        return try client.decode(data)
    }
    
    
    public struct TranslationsParameter: Codable {
        // Required: The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
        public var file: String
        
        // Required: ID of the model to use. Only whisper-1 is currently available.
        public var model: Model
        
        // Optional: An optional text to guide the model's style or continue a previous audio segment. The prompt should match the audio language.
        public var prompt: String?
        
        // Optional: Defaults to json. The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
        public var response_format: ResponseFormat
        
        // Optional: Defaults to 0. The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use log probability to automatically increase the temperature until certain thresholds are hit.
        public var temperature: Double?
        
        public init(file: String,
                    model: Model = .whisper_1,
                    prompt: String? = nil,
                    response_format: ResponseFormat = .json,
                    temperature: Double? = nil) {
            self.file = file
            self.model = model
            self.prompt = prompt
            self.response_format = response_format
            self.temperature = temperature
        }
    }
    
    public func translations(_ parameter: TranscriptionsParameter, data: Data) async throws -> Transcription {
        var request = client.request(of: serivce, path: "v1/audio/translations")
        request.method = .post
        request.headerFields[.contentType] = "multipart/form-data; boundary=\(UUID().uuidString)"
        let data = try await client.upload(for: request, from: data)
        return try client.decode(data)
    }
    
    
}
