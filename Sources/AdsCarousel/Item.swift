//
//  File.swift
//  
//
//  Created by Thomas on 18/07/2023.
//

#if canImport(UIKit)

import UIKit

enum Section: CaseIterable {
    case main
}

public class Item: Hashable {
    let url: URL
    let targetUrl: URL?
    let identifier = UUID()
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public init(url: URL, targetUrl: URL?) {
        self.url = url
        self.targetUrl = targetUrl
    }
}

#endif
