//
//  DecoderTests.swift
//  
//
//  Created by linhey on 2023/11/17.
//

import XCTest
import OpenAICore
import STJSON

final class DecoderTests: XCTestCase {
    
    func test_decode_request_default() throws {
        let json = """
        {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content": "You are a helpful assistant."
              },
              {
                "role": "user",
                "content": "Hello!"
              }
            ]
          }
        """
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateParameter.self, from: json)
        XCTAssert(object.model == .gpt35_turbo)
        XCTAssert(object.messages.count == 2)
        XCTAssert(object.messages[0].role == .system)
        XCTAssert(object.messages[0] == .system(.init(content: "You are a helpful assistant.")))
        XCTAssert(object.messages[1].role == .user)
        XCTAssert(object.messages[1] == .user("Hello!"))
    }
    
    func test_decode_request_image_input() throws {
        let json = """
        {
            "model": "gpt-4-vision-preview",
            "messages": [
              {
                "role": "user",
                "content": [
                  {
                    "type": "text",
                    "text": "What’s in this image?"
                  },
                  {
                    "type": "image_url",
                    "image_url": {
                      "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
                    }
                  }
                ]
              }
            ],
            "max_tokens": 300
          }
        """
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateParameter.self, from: json)
        XCTAssert(object.model == .gpt4_vision_preview)
        XCTAssert(object.messages.count == 1)
        XCTAssert(object.messages[0].role == .user)
        XCTAssert(object.messages[0] == .user([
            .text("What’s in this image?"),
            .image_url("https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")
        ]))
    }

    func test_decode_request_functions() throws {
        let json = """
        {
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content": "What is the weather like in Boston?"
            }
          ],
          "tools": [
            {
              "type": "function",
              "function": {
                "name": "get_current_weather",
                "description": "Get the current weather in a given location",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "location": {
                      "type": "string",
                      "description": "The city and state, e.g. San Francisco, CA"
                    },
                    "unit": {
                      "type": "string",
                      "enum": ["celsius", "fahrenheit"]
                    }
                  },
                  "required": ["location"]
                }
              }
            }
          ],
          "tool_choice": "auto"
        }
        """
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateParameter.self, from: json)
        XCTAssert(object.model == .gpt35_turbo)
        XCTAssert(object.messages.count == 1)
        XCTAssert(object.tools == [.function(.init(name: "get_current_weather",
                                                   description: "Get the current weather in a given location",
                                                   parameters: [
                                                    "type": "object",
                                                    "properties": [
                                                      "location": [
                                                        "type": "string",
                                                        "description": "The city and state, e.g. San Francisco, CA"
                                                      ],
                                                      "unit": [
                                                        "type": "string",
                                                        "enum": ["celsius", "fahrenheit"]
                                                      ]
                                                    ],
                                                    "required": ["location"]
                                                   ]))])
        XCTAssert(object.messages[0].role == .user)
        XCTAssert(object.messages[0] == .user(.text("What is the weather like in Boston?")))
    }
    
    func test_decode_request_logprobs() throws {
        let json = """
        {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content": "Hello!"
              }
            ],
            "logprobs": true,
            "top_logprobs": 2
          }
        """
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateParameter.self, from: json)
        XCTAssert(object.model == .gpt35_turbo)
        XCTAssert(object.logprobs == true)
        XCTAssert(object.top_logprobs == 2)
        XCTAssert(object.messages.count == 1)
        XCTAssert(object.messages[0].role == .user)
        XCTAssert(object.messages[0] == .user("Hello!"))
    }
    
    func test_decode_respose_default() throws {
        let json = #"""
        {
          "id": "chatcmpl-123",
          "object": "chat.completion",
          "created": 1677652288,
          "model": "gpt-3.5-turbo-0125",
          "system_fingerprint": "fp_44709d6fcb",
          "choices": [{
            "index": 0,
            "message": {
              "role": "assistant",
              "content": "\n\nHello there, how may I assist you today?"
            },
            "logprobs": null,
            "finish_reason": "stop"
          }],
          "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 12,
            "total_tokens": 21
          }
        }
        """#
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateResponse.self, from: json)
        XCTAssert(object.id == "chatcmpl-123")
        XCTAssert(object.object == .chat_completion)
        XCTAssert(object.created == 1677652288)
        XCTAssert(object.model == "gpt-3.5-turbo-0125")
        XCTAssert(object.system_fingerprint == "fp_44709d6fcb")
        XCTAssert(object.usage == .init(prompt_tokens: 9, completion_tokens: 12, total_tokens: 21))
        XCTAssert(object.choices == [
            .init(index: 0,
                  message: .init(role: .assistant, content: "\n\nHello there, how may I assist you today?"),
                  logprobs: nil,
                  finish_reason: .stop)
        ])
    }

    func test_decode_respose_function() throws {
        let json = #"""
        {
          "id": "chatcmpl-abc123",
          "object": "chat.completion",
          "created": 1699896916,
          "model": "gpt-3.5-turbo-0125",
          "choices": [
            {
              "index": 0,
              "message": {
                "role": "assistant",
                "content": null,
                "tool_calls": [
                  {
                    "id": "call_abc123",
                    "type": "function",
                    "function": {
                      "name": "get_current_weather",
                      "arguments": "{\n\"location\": \"Boston, MA\"\n}"
                    }
                  }
                ]
              },
              "logprobs": null,
              "finish_reason": "tool_calls"
            }
          ],
          "usage": {
            "prompt_tokens": 82,
            "completion_tokens": 17,
            "total_tokens": 99
          }
        }
        """#
        let object = try JSONDecoder.decode(OAIChatCompletion.CreateResponse.self, from: json)
        XCTAssert(object.id == "chatcmpl-abc123")
        XCTAssert(object.object == .chat_completion)
        XCTAssert(object.created == 1699896916)
        XCTAssert(object.model == "gpt-3.5-turbo-0125")
        XCTAssert(object.usage == .init(prompt_tokens: 82, completion_tokens: 17, total_tokens: 99))
        XCTAssert(object.choices == [
            .init(index: 0,
                  message: .init(role: .assistant, tool_calls: [
                    .init(id: "call_abc123",
                          type: .function,
                          function: .init(name: "get_current_weather",
                                          arguments: "{\n\"location\": \"Boston, MA\"\n}"))
                  ]),
                  logprobs: nil,
                  finish_reason: .tool_calls)
        ])
    }

    func test_decode_respose_streaming() throws {
        let strings = [
            #"{"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-3.5-turbo-0125", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"role":"assistant","content":""},"logprobs":null,"finish_reason":null}]}"#,
            #"{"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-3.5-turbo-0125", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"content":"Hello"},"logprobs":null,"finish_reason":null}]}"#,
            #"{"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-3.5-turbo-0125", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{},"logprobs":null,"finish_reason":"stop"}]}"#
        ]
    }
}
