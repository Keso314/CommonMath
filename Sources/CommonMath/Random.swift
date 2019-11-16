//
//  Random.swift
//  DummyGraph
//
//  Created by Jon Sturk on 22/08/15.
//  Copyright © 2015 Jon Sturk. All rights reserved.
//

import Foundation
import GameplayKit

public protocol RandomSource {
	func nextUniform() -> Double //[0.0, 1.0]
	func nexInt(_ maxValue: Int) -> Int
}

public struct GKRandomWrapper: RandomSource {
	let gkrandom: GKRandom
	
	public init(gkrandom rand: GKRandom) {
		self.gkrandom = rand
	}
	
	public func nextUniform() -> Double {
		return Double(gkrandom.nextUniform()) //WARNING: Note that this is actually a float.
	}
	
	public func nexInt(_ maxValue: Int) -> Int {
		return gkrandom.nextInt(upperBound: maxValue)
	}
}
