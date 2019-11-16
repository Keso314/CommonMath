//
//  Geometry.swift
//  DummyGraph
//
//  Created by Jon Sturk on 21/10/15.
//  Copyright © 2015 Jon Sturk. All rights reserved.
//

import Foundation
import simd
/*
func convexHull(_ vertices: [VoronoiVertex]) throws -> [VoronoiVertex] {
	let extreme = getExtremePoints(vertices)
	let baseline = getBaseline(extreme)
	let third = findFurtestPointFromSegmentFrom(baseline.0, to: baseline.1, inPoints: baseline.2)
	let tp = third.position
	let v1 = baseline.0.position - tp
	let v2 = baseline.1.position - tp
	
	let norm = v1.cross(v2)
	let tmp = tp.dot(norm) * -1
	
	let splitPlane = JSPlane(a: norm.x, b: norm.y, c: norm.z, d: tmp)
	
	let fourth = findFurtestPointFromPlane(splitPlane, inPoints: Set<VoronoiVertex>(vertices))
	
	do {
		var faceStack = [(face: QHFace, outside: [JSVector3])]()
		
		let tetra = try buildQHTetrahedon([baseline.0.position, baseline.1.position, tp, fourth.position])
		var outLists = [QHFace: [JSVector3]]()
		for face in tetra {
			outLists[face] = [JSVector3]()
		}
		for v in baseline.2 {
			for face in tetra {
				if face.plane.isPointInFront(v.position) {
					outLists[face]!.append(v.position)
				}
			}
		}
		for face in tetra {
			faceStack.append((face, outLists[face]!))
		}
		
		outLists.removeAll()
		
		while faceStack.count > 0 {
			let (face, outside) = faceStack.removeLast()
			let initial = (outside.first!, distanceFromPlane(plane: face.plane, toPoint: outside.first!))
			let (furthest, _) = outside.suffix(from: 1).reduce(initial) {
				let tmp = distanceFromPlane(plane: face.plane, toPoint: $1)
				return tmp > $0.1 ? ($1, tmp) : $0
			}
			var visited = [face]
			var visibilityStack = [face]
			
			while visibilityStack.count > 0 {
				let workItem = visibilityStack.removeLast()
				for neighbor in workItem.neighbors {
					if visited.contains(neighbor) {
						continue
					}
					if neighbor.plane.isPointInFront(furthest) {
						visibilityStack.append(neighbor)
						visited.append(neighbor)
					}
				}
			}
		}
		
	} catch let error as QHError {
		fatalError(error.message)
	}
	
	
	
	return []
}

func findFurtestPointFromSegmentFrom(_ from: VoronoiVertex, to: VoronoiVertex, inPoints points: Set<VoronoiVertex>) -> VoronoiVertex {
	if points.count == 0 {
		fatalError("BOOM!")
	} else if points.count == 1 {
		return points.first!
	}
	var max: (Double, VoronoiVertex?) = (-Double.infinity, nil)
	
	for p in points {
		let dist = distanceFromLineSegmentFrom(from, to: to, toPoint: p)
		if dist > max.0 {
			max = (dist, p)
		}
	}
	
	return max.1!
}

func findFurtestPointFromPlane(_ plane: JSPlane, inPoints points: Set<VoronoiVertex>) -> VoronoiVertex {
	var points = points
	var max = points.first!
	points.remove(max)
	var maxDist = abs(distanceFromPlane(plane: plane, toPoint: max.position))
	
	for p in points {
		let tmpDist = abs(distanceFromPlane(plane: plane, toPoint: p.position))
		if tmpDist > maxDist {
			maxDist = tmpDist
			max = p
		}
	}
	return max
}

func distanceFromLineSegmentFrom(_ from: VoronoiVertex, to: VoronoiVertex, toPoint point: VoronoiVertex) -> Double {
	let Q = point.position - from.position
	let L = to.position - from.position
	
	let cross = L.cross(Q)
	let norm = cross.cross(L).normalized()
	
	return L.dot(norm)
}

func getBaseline(_ extreme: Set<VoronoiVertex>) -> (v0: VoronoiVertex, v1: VoronoiVertex, other: Set<VoronoiVertex>) {
	var extreme = extreme
	if extreme.count == 2 {
		return (extreme.removeFirst(), extreme.removeFirst(), [])
	}
	
	var maxDist = (extreme.first!, extreme.first!, -Double.infinity)
	
	for outer in extreme {
		for inner in extreme where inner != outer {
			let dist = (inner.position - outer.position).length2
			if dist > maxDist.2 {
				maxDist = (outer, inner, dist)
			}
		}
	}
	extreme.remove(maxDist.0)
	extreme.remove(maxDist.1)
	
	return (maxDist.0, maxDist.1, extreme)
}

func getExtremePoints(_ vertices: [VoronoiVertex]) -> Set<VoronoiVertex> {
	guard let first = vertices.first else {
		return []
	}
	var minX = first
	var maxX = first
	var minY = first
	var maxY = first
	var minZ = first
	var maxZ = first
	
	for v in vertices {
		let cp = v.position
		if cp.x < minX.position.x {
			minX = v
		} else if cp.x > maxX.position.x {
			maxX = v
		}
		if cp.y < minY.position.y {
			minY = v
		} else if cp.y > maxY.position.y {
			maxY = v
		}
		if cp.z < minZ.position.z {
			minZ = v
		} else if cp.z > maxZ.position.z {
			maxZ = v
		}
	}
	
	var eps = Set<VoronoiVertex>()
	eps.insert(minX)
	eps.insert(maxX)
	eps.insert(minY)
	eps.insert(maxY)
	eps.insert(minZ)
	eps.insert(maxZ)
	
	return eps
}

*/

public struct AABB<T>: Equatable where T : SIMDScalar, T : FloatingPoint {
	public let min: SIMD3<T>
	public let max: SIMD3<T>
	
	public init() {
		self.init(min: SIMD3<T>(x: T.infinity, y: T.infinity, z: T.infinity), max: SIMD3<T>(x: -T.infinity, y: -T.infinity, z: -T.infinity))
	}
	
	public init(min: SIMD3<T>, max: SIMD3<T>) {
		self.min = min
		self.max = max
	}
	
	public func join(_ other: AABB<T>) -> AABB<T> {
		let newMin = SIMD3<T>(x: Swift.min(min.x, other.min.x), y: Swift.min(min.y, other.min.y), z: Swift.min(min.z, other.min.z))
		let newMax = SIMD3<T>(x: Swift.max(max.x, other.max.x), y: Swift.max(max.y, other.max.y), z: Swift.max(max.z, other.max.z))
		
		return AABB(min: newMin, max: newMax)
	}
}

public func == <T : FloatingPoint> (lhs: AABB<T>, rhs: AABB<T>) -> Bool {
	return lhs.min == rhs.min && lhs.max == rhs.max
}

public func == (lhs: Elipse, rhs: Elipse) -> Bool {
	return lhs.eccentricity == rhs.eccentricity && lhs.semiMajorAxis == rhs.semiMajorAxis
}

public struct Elipse: Equatable {
	public let semiMajorAxis: Double
	public let eccentricity: Double
	
	public init(semiMajorAxis a: Double, eccentricity e: Double) {
		//		precondition(e >= 0 && e < 1) //For elipses, e must be >= 0 (0 makes a circle) and < 1
		self.semiMajorAxis = a
		self.eccentricity = e
	}
	
	public var apoapsis: Double {
		return semiMajorAxis * (1 + eccentricity)
	}
	
	public var periapsis: Double {
		return semiMajorAxis * (1 - eccentricity)
	}
	
	public var focus: Double {
		return semiMajorAxis * eccentricity
	}
	
	public var semiMinorAxis: Double {
		return semiMajorAxis * sqrt(1 - eccentricity * eccentricity)
	}
	
	public var perimiter: Double {
		let h = pow((semiMajorAxis - semiMinorAxis), 2.0) / pow((semiMajorAxis + semiMinorAxis), 2.0)
		
		return Double.pi * (semiMajorAxis + semiMinorAxis) * (1.0 + ((3 * h) / (10 + sqrt(4 - 3 * h))))
	}
}

public struct Angle<T: FloatingPoint>: Equatable {
	public let radians: T
	public var degrees: T {
		return (radians / T.pi) * 180
	}
	
	public init(radians: T) {
		self.radians = radians
	}
	
	public init(degrees: T) {
		self.radians = (degrees / 180) * T.pi
	}
}

public func == <T: FloatingPoint> (lhs: Angle<T>, rhs: Angle<T>) -> Bool {
	return abs(lhs.radians - rhs.radians) < (T.leastNonzeroMagnitude * 10)
}

public struct Distance<T: FloatingPoint>: Equatable {
	public let m: T
	public var km: T {
		return m / 1000
	}
	public var au: T {
		return m / 149597870700
	}
	
	public init(m: T) {
		self.m = m
	}
	
	public init(km: T) {
		self.m = km * 1000
	}
	
	public init(au: T) {
		self.m = au * 149597870700
	}
}

public func == <T: FloatingPoint> (lhs: Distance<T>, rhs: Distance<T>) -> Bool {
	return abs(lhs.m - rhs.m) < (T.leastNonzeroMagnitude * 10)
}

