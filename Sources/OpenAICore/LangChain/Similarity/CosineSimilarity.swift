//
//  File.swift
//  
//
//  Created by linhey on 2024/4/22.
//

import Foundation

public protocol LLMVectorSimilarity {
    func compare(_ lhs: Float, _ rhs: Float) throws -> Bool
    func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float
}

public struct DotSimilarity: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs > rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        return zip(vector1, vector2).map(*).reduce(0, +)
    }

}

/**
 余弦相似度
 描述：余弦相似度测量两个向量在方向上的相似程度，而忽略它们的大小。
 计算方法：通过计算两个向量的点积和它们的模长来得到余弦值。
 适用场景：文本数据的相似度计算（如TF-IDF权重向量），因为它比较的是方向而不是向量大小。
 */
public struct CosineSimilarity: LLMVectorSimilarity {
   
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs > rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        let magA = magnitude(vector1)
        let magB = magnitude(vector2)
        return dot(vector1, vector2) / (magA * magB)
    }
    
    private func dot(_ vector1: [Float32], _ vector2: [Float32]) -> Float {
        return zip(vector1, vector2).map(*).reduce(0, +)
    }
    
    private func magnitude(_ vector: [Float32]) -> Float {
        return sqrt(vector.map { $0 * $0 }.reduce(0, +))
    }
    
}

/**
 杰卡德相似度（Jaccard Similarity）
 描述：度量两个集合中交集与并集的比例。
 应用：当文本被转化为词集合（不考虑词频）时适用，如关键词集合的相似度测量。
 */
public struct JaccardSimilarity: LLMVectorSimilarity {
    
    public init() {}
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        .init(try self.distance(vector1, vector2))
    }
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs > rhs
    }
    
    public static func distance(_ set1: any StringProtocol, _ set2: any StringProtocol) -> Double {
        self.distance(set1.map(\.description), set2.map(\.description))
    }
    
    public static func distance<T: Hashable>(_ set1: any Collection<T>, _ set2: any Collection<T>) -> Double {
        self.distance(Set(set1), Set(set2))
    }
    
    public static func distance<T: Hashable>(_ set1: Set<T>, _ set2: Set<T>) -> Double {
        let intersection = set1.intersection(set2).count
        let union = set1.union(set2).count
        return union == 0 ? 0 : Double(intersection) / Double(union)
    }

}

/**
 欧几里得距离（Euclidean Distance）
描述：计算两个向量间的“直线”距离。
应用：当向量的大小和距离对比较结果有重要影响时适用，通常不适用于高维数据。
 */
public struct EuclideanDistance: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs < rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        let squaredDifferences = zip(vector1, vector2).map { ($0 - $1) * ($0 - $1) }
        return sqrt(squaredDifferences.reduce(0, +))
    }
    
}

/**
 布哈特距离（Bhattacharyya Distance）
 描述：用于测量两个概率分布之间的相似性。
 应用：适用于概率模型中，如主题模型或概率语义分析中。
 */
public struct BhattacharyyaDistance: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs < rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        var coefficient: Float = 0.0
        for (pi, qi) in zip(vector1, vector2) {
            coefficient += sqrt(pi * qi)
        }
        return -log(max(coefficient, Float.leastNormalMagnitude))
    }
    
}

/**
 Kullback-Leibler 散度（KL Divergence）
 描述：衡量两个概率分布之间的差异。
 应用：在自然语言处理中，可以用来衡量两个文本或单词分布的差异性。
 */
public struct KullbackLeiblerDivergence: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs < rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        var divergence: Float = 0.0
        
        for (p, q) in zip(vector1, vector2) {
            if p > 0, q > 0 {
                divergence += p * log(p / q)
            }
        }
        
        return divergence
    }
    
}


/**
 曼哈顿距离（Manhattan Distance）
 描述：计算两个向量在各个维度上差的绝对值之和。
 应用：适用于维度独立且等同重要的情况。
 */
public struct ManhattanDivergence: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs < rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        var distance: Float = 0.0
        
        for (p, q) in zip(vector1, vector2) {
            distance += abs(p - q)
        }
        
        return distance
    }
    
}


public struct PearsonCorrelation: LLMVectorSimilarity {
    
    public init() {}
    
    public func compare(_ lhs: Float, _ rhs: Float) throws -> Bool {
        lhs > rhs
    }
    
    public func distance(_ vector1: [Float], _ vector2: [Float]) throws -> Float {
        let meanX = vector1.reduce(0, +) / Float(vector1.count)
        let meanY = vector2.reduce(0, +) / Float(vector2.count)

        var numerator: Float = 0.0
        var sumSqX: Float = 0.0
        var sumSqY: Float = 0.0
        for (x, y) in zip(vector1, vector2) {
            numerator += (x - meanX) * (y - meanY)
            sumSqX += (x - meanX) * (x - meanX)
            sumSqY += (y - meanY) * (y - meanY)
        }

        let denominator = sqrt(sumSqX * sumSqY)
        return numerator / denominator
    }
    
}
