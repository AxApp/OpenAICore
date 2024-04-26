//
//  File.swift
//  
//
//  Created by linhey on 2024/4/19.
//


import Foundation

public enum OllamaModel: String {
    case phi3
    case llama3
    case wizardlm2
    case mistral
    case gemma
    case mixtral
    case llama2
    case codegemma
    case command_r = "command-r"
    case command_r_plus = "command-r-plus"
    case llava
    case dbrx
    case codellama
//    case dolphin-mixtral
    case qwen
//    case llama2-uncensored
//    case mistral-openorca
//    case deepseek-coder
    case phi
//    case nous-hermes2
//    case dolphin-mistral
//    case orca-mini
//    case nomic-embed-text
//    case llama2-chinese
    case zephyr
//    case wizard-vicuna-uncensored
    case openhermes
    case vicuna
    case tinydolphin
    case tinyllama
    case openchat
    case starcoder2
    case wizardcoder
//    case stable-code
    case starcoder
//    case neural-chat
//    case phind-codellama
    case yi
//    case starling-lm
//    case dolphin-phi
    case falcon
    case orca2
//    case wizard-math
    case dolphincoder
//    case nous-hermes
    case bakllava
    case medllama2
    case solar
//    case nous-hermes2-mixtral
    case sqlcoder
//    case wizardlm-uncensored
//    case mxbai-embed-large
    case codeup
    case everythinglm
    case stablelm2
//    case all-minilm
//    case yarn-mistral
//    case samantha-mistral
    case meditron
//    case stable-beluga
    case magicoder
//    case stablelm-zephyr
//    case yarn-llama2
//    case llama-pro
//    case deepseek-llm
    case codebooga
//    case dolphin-llama3
    case mistrallite
//    case wizard-vicuna
    case nexusraven
    case codeqwen
    case goliath
//    case open-orca-platypus2
    case notux
    case megadolphin
    case alfred
//    case duckdb-nsql
    case xwinlm
    case wizardlm
    case notus
    case snowflake_arctic_embed = "snowflake-arctic-embed"
}

public struct OllamaGenerate {
    
    public struct Parameters: Codable {
        
        public var model: String
        public var prompt: String
        public var images: [String]?
        public var format: OllamaResponseFormat?
        public var options: GenerateOptions?
        public var system: String?
        public var template: String?
        public var context: String?
        public var stream: Bool
        public var raw: Bool?
        public var keep_alive: String?
        
        public init(model: String,
                    prompt: String,
                    images: [String]? = nil,
                    format: OllamaResponseFormat? = nil,
                    options: GenerateOptions? = nil,
                    system: String? = nil,
                    template: String? = nil,
                    context: String? = nil,
                    stream: Bool = false,
                    raw: Bool? = nil,
                    keep_alive: String? = nil) {
            self.model = model
            self.prompt = prompt
            self.images = images
            self.format = format
            self.options = options
            self.system = system
            self.template = template
            self.context = context
            self.stream = stream
            self.raw = raw
            self.keep_alive = keep_alive
        }
    }
    
    public struct GenerateOptions: Codable {
        public var temperature: Double?
        public var seed: Int?
        public var num_keep: Int?
        public var num_predict: Int?
        public var top_k: Int?
        public var top_p: Double?
        public var tfs_z: Double?
        public var typical_p: Double?
        public var repeat_last_n: Int?
        public var repeat_penalty: Double?
        public var presence_penalty: Double?
        public var frequency_penalty: Double?
        public var mirostat: Bool?
        public var mirostat_tau: Double?
        public var mirostat_eta: Double?
        public var penalize_newline: Bool?
        public var stop: [String]?
        public var numa: Bool?
        public var num_ctx: Int?
        public var num_batch: Int?
        public var num_gqa: Int?
        public var num_gpu: Int?
        public var main_gpu: Int?
        public var low_vram: Bool?
        public var f16_kv: Bool?
        public var vocab_only: Bool?
        public var use_mmap: Bool?
        public var use_mlock: Bool?
        public var rope_frequency_base: Double?
        public var rope_frequency_scale: Double?
        public var num_thread: Int?
    }

    public struct StreamResponse: Codable {
        public var model: String
        public var created_at: String
        public var response: String
        public var done: Bool
        
        mutating func merge(stream: StreamResponse) {
            self.model = stream.model
            self.created_at = stream.created_at
            self.done = stream.done
            self.response += stream.response
        }
    }
    
    public struct Response: Codable {
        public var model: String
        public var created_at: String
        public var response: String
        public var done: Bool
        public var context: [Int]?
        public var total_duration: Int64?
        public var load_duration: Int64?
        public var prompt_eval_count: Int?
        public var prompt_eval_duration: Int64?
        public var eval_count: Int?
        public var eval_duration: Int64?
        
        init(model: String, created_at: String, response: String, done: Bool, context: [Int]? = nil, total_duration: Int64, load_duration: Int64, prompt_eval_count: Int, prompt_eval_duration: Int64, eval_count: Int, eval_duration: Int64) {
            self.model = model
            self.created_at = created_at
            self.response = response
            self.done = done
            self.context = context
            self.total_duration = total_duration
            self.load_duration = load_duration
            self.prompt_eval_count = prompt_eval_count
            self.prompt_eval_duration = prompt_eval_duration
            self.eval_count = eval_count
            self.eval_duration = eval_duration
        }
    }
    
    
}
