import Foundation

public struct SSEParser {
    
    public enum MessageKind: String {
        case data
        case id
        case event
        case comment
    }
    
    public struct Message {
        
        public var kind: MessageKind
        public var value: String
        
        public init(kind: MessageKind, value: String) {
            self.kind = kind
            self.value = value
        }
        
        public init?(parse component: String) {
            
            func match(by kind: MessageKind) -> String? {
                if component.hasPrefix("\(kind.rawValue):") {
                    return String(component.dropFirst("\(kind.rawValue):".count)).trimmingCharacters(in: .whitespaces)
                } else {
                    return nil
                }
            }
            if let value = match(by: .data) {
                self.kind = .data
                self.value = value
            } else if let value = match(by: .id) {
                self.kind = .id
                self.value = value
            } else if let value = match(by: .event) {
                self.kind = .event
                self.value = value
            } else if let value = match(by: .comment) {
                self.kind = .comment
                self.value = value
            } else {
                return nil
            }
        }
    }
    
    public static func parse(from data: String) -> [Message] {
        return data
            .components(separatedBy: "\n")
            .compactMap(Message.init(parse:))
    }
    
}
