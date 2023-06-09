//
//  File.swift
//  
//
//  Created by linhey on 2023/3/23.
//

import Foundation

///MARK: - Completions
public struct OAICompletions: OAIAPI {    

    public let path: OAIPath = .completions
    public let query: Query
    
    public init(query: Query) {
        self.query = query
    }
    
    public struct Query: Codable, OAIAPIQuery {
        /// ID of the model to use.
        public let model: String
        /// The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
        public let prompt: String
        /// What sampling temperature to use. Higher values means the model will take more risks. Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
        public let temperature: Double?
        /// The maximum number of tokens to generate in the completion.
        public let max_tokens: Int?
        /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
        public let top_p: Double?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
        public let frequency_penalty: Double?
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
        public let presence_penalty: Double?
        /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
        public let stop: [String]?
        /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        public let user: String?
        
        public init(model: OpenAIModel,
                    prompt: String,
                    temperature: Double? = nil,
                    max_tokens: Int? = nil,
                    top_p: Double? = nil,
                    frequency_penalty: Double? = nil,
                    presence_penalty: Double? = nil,
                    stop: [String]? = nil,
                    user: String? = nil) {
            self.model = model.name
            self.prompt = prompt
            self.temperature = temperature
            self.max_tokens = max_tokens
            self.top_p = top_p
            self.frequency_penalty = frequency_penalty
            self.presence_penalty = presence_penalty
            self.stop = stop
            self.user = user
        }
    }
    
    public struct Response: Codable {
        public struct Choice: Codable {
            public let text: String
            public let index: Int
        }

        public let id: String
        public let object: String
        public let created: TimeInterval
        public let model: String
        public let choices: [Choice]
    }
    
}
