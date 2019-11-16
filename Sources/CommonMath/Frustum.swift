//
//  VSD.swift
//  DummyGraph
//
//  Created by Jon Sturk on 07/11/15.
//  Copyright © 2015 Jon Sturk. All rights reserved.
//

import Foundation
import simd

public enum IntersectTestResult {
	case outside, intersect, inside, unknown
}

public struct JSFrustum<T> where T : FloatingPoint, T : SIMDScalar {
	public var planes = [JSPlane<T>]()
	public var point: SIMD3<T>
	
	public init(point p: SIMD3<T>, planes: [JSPlane<T>]) {
		self.point = p
		self.planes = planes
	}
	
	public func testIntersection(_ bounds: AABB<T>) -> IntersectTestResult {
		var farVertex: SIMD3<T>!
		var nearVertex: SIMD3<T>!
		
		var result = IntersectTestResult.inside
		
		for p in planes {
			let sx = sign(p.normal.x)
			let sy = sign(p.normal.y)
			let sz = sign(p.normal.z)
			
			if sx >= 0 {
				if sy >= 0 {
					if sz >= 0 {
						farVertex = SIMD3<T>(x: bounds.min.x, y: bounds.min.y, z: bounds.min.z)
						nearVertex = SIMD3<T>(x: bounds.max.x, y: bounds.max.y, z: bounds.max.z)
					} else {
						farVertex = SIMD3<T>(x: bounds.min.x, y: bounds.min.y, z: bounds.max.z)
						nearVertex = SIMD3<T>(x: bounds.max.x, y: bounds.max.y, z: bounds.min.z)
					}
				} else {
					if sz >= 0 {
						farVertex = SIMD3<T>(x: bounds.min.x, y: bounds.max.y, z: bounds.min.z)
						nearVertex = SIMD3<T>(x: bounds.max.x, y: bounds.min.y, z: bounds.max.z)
					} else {
						farVertex = SIMD3<T>(x: bounds.min.x, y: bounds.max.y, z: bounds.max.z)
						nearVertex = SIMD3<T>(x: bounds.max.x, y: bounds.min.y, z: bounds.min.z)
					}
				}
			} else {
				if sy >= 0 {
					if sz >= 0 {
						farVertex = SIMD3<T>(x: bounds.max.x, y: bounds.min.y, z: bounds.min.z)
						nearVertex = SIMD3<T>(x: bounds.min.x, y: bounds.max.y, z: bounds.max.z)
					} else {
						farVertex = SIMD3<T>(x: bounds.max.x, y: bounds.min.y, z: bounds.max.z)
						nearVertex = SIMD3<T>(x: bounds.min.x, y: bounds.max.y, z: bounds.min.z)
					}
				} else {
					if sz >= 0 {
						farVertex = SIMD3<T>(x: bounds.max.x, y: bounds.max.y, z: bounds.min.z)
						nearVertex = SIMD3<T>(x: bounds.min.x, y: bounds.min.y, z: bounds.max.z)
					} else {
						farVertex = SIMD3<T>(x: bounds.max.x, y: bounds.max.y, z: bounds.max.z)
						nearVertex = SIMD3<T>(x: bounds.min.x, y: bounds.min.y, z: bounds.min.z)
					}
				}
			}
			if p.isPointInFront(nearVertex) == false {
				return .outside
			}
			if p.isPointInFront(farVertex) == false {
				result = .intersect
			}
		}
		return result
	}
}
