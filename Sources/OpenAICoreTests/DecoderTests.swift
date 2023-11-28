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

    func test_chat_completion() throws {
        let object = try JSONDecoder.decode(OAIChatCompletion.self, from: #"""
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-3.5-turbo-0613",
  "system_fingerprint": "fp_44709d6fcb",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "\n\nHello there, how may I assist you today?"
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 12,
    "total_tokens": 21
  }
}
"""#)
        XCTAssert(object.id == "chatcmpl-123")
        XCTAssert(object.usage == OAIUsage(prompt_tokens: 9, completion_tokens: 12, total_tokens: 21))
    }
    
    func test_chat_completion_image_functions() throws {
        var parameter = OAIChatCompletionAPIs.CreateParameter()
         parameter.model = .gpt35Turbo
        parameter.tool_choice = .auto
        parameter.tools = [
            .function(.init(function: .init(name: "get_current_weather",
                                            description: "Get the current weather in a given location",
                                            parameters: #"""
         {
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
"""#)))
        ]
         parameter.messages = [
            .init(role: .user, content: [.text("What is the weather like in Boston?")]),
         ]
         
         XCTAssert(try parameter.encode() == JSON(parseJSON: #"""
 {
   "model": "gpt-3.5-turbo",
  "messages" : [
    {
      "content" : [
        {
          "text" : "What is the weather like in Boston?",
          "type" : "text"
        }
      ],
      "role" : "user"
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
 """#))
        
        
        let object = try JSONDecoder.decode(OAIChatCompletion.self, from: #"""
{
  "id": "chatcmpl-8LqLlQFfCirQa4Go69yhLF4JyKhxD",
  "object": "chat.completion",
  "created": 1700216813,
  "model": "gpt-3.5-turbo-0613",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_v9PLa6k3LKT4avu9Jqidlazz",
            "type": "function",
            "function": {
              "name": "get_current_weather",
              "arguments": "{\n  \"location\": \"Boston, MA\"\n}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ],
  "usage": {
    "prompt_tokens": 82,
    "completion_tokens": 18,
    "total_tokens": 100
  }
}
"""#)
        XCTAssert(object.id == "chatcmpl-8LqLlQFfCirQa4Go69yhLF4JyKhxD")
        XCTAssert(object.usage == OAIUsage(prompt_tokens: 82, completion_tokens: 18, total_tokens: 100))
        XCTAssert(object.choices.first?.message.tool_calls?.first?.id == "call_v9PLa6k3LKT4avu9Jqidlazz")
        XCTAssert(object.choices.first?.message.tool_calls?.first?.function.name == "get_current_weather")
        XCTAssert(object.choices.first?.message.tool_calls?.first?.function.arguments == #"{\n  \"location\": \"Boston, MA\"\n}"#)
        XCTAssert(object.choices.first!.finish_reason! == .tool_calls)
    }
    
    func test_chat_completion_image_input() throws {
       var parameter = OAIChatCompletionAPIs.CreateParameter()
        parameter.model = .gpt4_vision_preview
        parameter.max_tokens = 300
        parameter.messages = [
            .init(role: .user, content: [
                .text("What’s in this image?"),
                .image_url("https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")
            ]),
        ]
        
        XCTAssert(try parameter.encode() == JSON(parseJSON: #"""
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
"""#))
    }
    
    func test_chat_completion_chunk_object() throws {
        let texts = #"""
data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"随"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"机"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"本"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"是"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"指"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"没有"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"特"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"定"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"含"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"义"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"、"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"目"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"的"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"或"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"结"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"构"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"的"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文字"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"。"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"它"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"可以"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"用"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"于"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"各"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"种"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"场"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"合"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"，"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"比"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"如"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"测试"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"字"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"体"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"显示"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"效"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"果"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"、"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"填"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"充"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"模"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"板"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"以"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"展"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"示"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"版"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"面"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"设计"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"等"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"。"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"下"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"面"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"是"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"一"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"段"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"随"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"机"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"本"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"示"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"例"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"：\n\n"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"\""},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"Lorem"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ipsum"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" dolor"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" sit"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" amet"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":","},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" consectetur"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" adipiscing"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" elit"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"."},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" Sed"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" do"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" eiusmod"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" tempor"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" incididunt"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ut"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" labore"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" et"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" dolore"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" magna"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" aliqua"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"."},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" Ut"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" enim"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ad"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" minim"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" veniam"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":","},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" quis"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" nostr"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"ud"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" exercitation"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ullam"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"co"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" labor"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"is"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" nisi"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ut"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" aliqu"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"ip"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ex"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" ea"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" commodo"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":" consequat"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":".\"\n\n"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"这"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"段"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"本"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"来"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"自"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"一个"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"被"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"广"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"泛"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"使用"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"的"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"拉"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"丁"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"语"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"乱"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"数"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"假"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"，"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"通"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"常"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"在"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"打"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"印"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"和"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"排"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"版"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"行"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"业"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"中"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"作"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"为"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"占"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"位"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"符"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"使用"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"。"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"如果"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"你"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"需要"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"其他"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"类型"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"或"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"语"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"言"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"的"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"随"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"机"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"文"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"本"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"，请"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"告"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"诉"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"我"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"具"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"体"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"要"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"求"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"，"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"我"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"可以"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"生成"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"更"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"多"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"样"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"化"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"的"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"内容"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{"content":"。"},"finish_reason":null}]}

data: {"id":"chatcmpl-8Lo8GaxfsiDRfhE643c2ZWszi4eG4","object":"chat.completion.chunk","created":1700208288,"model":"gpt-4-1106-preview","system_fingerprint":"fp_a24b4d720c","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
"""#
        let stream = OAIChatCompletionStreamMerge()
        let chunks = try stream.chunk(of: texts.data(using: .utf8)!)
        stream.merge(chunks)
        print(stream.completion)
    }

}
