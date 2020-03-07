//
//  Realm+Fuse.swift
//  Pods-RealmFuse_Example
//
//  Created by Layman on 2020/3/7.
//

import Foundation
import RealmSwift
import Fuse


public struct FuseProperty {
    let name: String
    let weight: Double

    public init (name: String) {
        self.init(name: name, weight: 1)
    }

    public init (name: String, weight: Double) {
        self.name = name
        self.weight = weight
    }
}

public protocol Fuseable {
    var fuseProperties: [FuseProperty] { get }
}

public typealias FuseSearchResult<Element: Fuseable & Object> = (
    element: Element,
    score: Double,
    results: [(
    key: String,
    score: Double,
    ranges: [CountableClosedRange<Int>]
    )]
)


// MARK: - Single Object

extension Fuseable where Self: Object {
    
    public func fuseSearch(_ text: String) -> FuseSearchResult<Self> {
        let fuse = Fuse()
        let pattern = fuse.createPattern(from: text)
        
        var totalScore = 0.0
        var propertyResults = [(key: String, score: Double, ranges: [CountableClosedRange<Int>])]()
        
        fuseProperties.forEach { property in
            guard let value = self.value(forKey: property.name) as? String else { return }
            if let result = fuse.search(pattern, in: value) {
                let weight = property.weight == 1 ? 1 : 1 - property.weight
                let score = (result.score == 0 && weight == 1 ? 0.001 : result.score) * weight
                totalScore += score
                propertyResults.append((key: property.name, score: score, ranges: result.ranges))
            }
        }
        return (
            element: self,
            score: totalScore,
            results: propertyResults
        )
    }
}


// MARK: - Results filter

extension Results where Element: Fuseable & Object{
    
    public func fuseSearch(_ text: String) -> [FuseSearchResult<Element>] {
        let fuse = Fuse()
        let pattern = fuse.createPattern(from: text)
        var collectionResult = [FuseSearchResult<Element>]()
        
        let lazyCollection = self.filter({ object in
            var totalScore = 0.0
            var propertyResults = [(key: String, score: Double, ranges: [CountableClosedRange<Int>])]()
            
            object.fuseProperties.forEach { property in
                guard let value = object.value(forKey: property.name) as? String else { return }
                if let result = fuse.search(pattern, in: value) {
                    let weight = property.weight == 1 ? 1 : 1 - property.weight
                    let score = (result.score == 0 && weight == 1 ? 0.001 : result.score) * weight
                    totalScore += score
                    propertyResults.append((key: property.name, score: score, ranges: result.ranges))
                }
            }
            guard propertyResults.count > 0 else { return false }
            collectionResult.append((
                element: object,
                score: totalScore/Double(propertyResults.count),
                results: propertyResults
            ))
            return true
        })
        // force filter to compute
        let _ = lazyCollection.count
        return collectionResult.sorted { $0.score < $1.score }
    }
}
