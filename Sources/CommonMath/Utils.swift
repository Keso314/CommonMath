//
//  Utils.swift
//  JSMath
//
//  Created by Jon Sturk on 2017-06-21.
//  Copyright © 2017 Jon Sturk. All rights reserved.
//

import Foundation
import simd
import Accelerate

public func distanceFromPlane<T: FloatingPoint>(plane p: JSPlane<T>, toPoint v: SIMD3<T>) -> T {
    return p.data.xyz.dot(other: v) + p.d
    
}
public func distanceFromPlane<T: FloatingPoint>(plane p: JSPlane<T>, toPoint v: SIMD4<T>) -> T {
    return distanceFromPlane(plane: p, toPoint: v.xyz)
}

public func polarToCartesian(theta: Float, phi: Float) -> SIMD3<Float> {
	return SIMD3<Float>(x: sin(theta) * cos(phi), y: sin(phi) * sin(theta) , z: cos(theta))
}

public func polarToCartesian(theta: Double, phi: Double) -> SIMD3<Double> {
    return SIMD3<Double>(x: sin(theta) * cos(phi), y: sin(phi) * sin(theta) , z: cos(theta))
}


public func diffD(values: [Double], dx: Double) -> [Double] {
	var v = values
	let v_o: UnsafePointer<Double> = &v + 1
	var out = [Double](repeating: 0.0, count: values.count - 1)
	var mod: Double = 1.0 / dx
    
	vDSP_vsbsmD(v_o, 1, &v, 1, &mod, &out, 1, UInt(out.count))
	return out
}

public func sign<T: FloatingPoint>(_ x: T) -> T {
	return (x > 0) ? 1 : ((x < 0) ? -1 : 0)
}

public enum Winding {
	case Clockwise, CounterClockwise, None
}

public func windingOrder(p0: SIMD3<Double>, p1: SIMD3<Double>, p2: SIMD3<Double>, referenceDirection rd: SIMD3<Double>) -> Winding {
	let v0 = p0 - p1
	let v1 = p2 - p1
	
	let dir = cross(v0, v1)
	let ang = dot(dir, rd)
	
	return ang > 0 ? .Clockwise : ang < 0 ? .CounterClockwise : .None
}

public func surfacePointsToRadians(a: SIMD3<Double>, b: SIMD3<Double>, c: SIMD3<Double>) -> (A: Double, B: Double, C: Double) {
	//All points must be on unit sphere.
	assert(abs(length_squared(a) - 1.0) < 1e-12)
	assert(abs(length_squared(b) - 1.0) < 1e-12)
	assert(abs(length_squared(c) - 1.0) < 1e-12)
	
	let ab = cross(b, a)
	let ac = cross(c, a)
	
	let lenAB = length(ab)
	let lenAC = length(ac)
	
	let cosA = dot(ab, ac) / (lenAB * lenAC)
	let A = acos(cosA)
	
	let ba = -ab // cross(a, b) // = -ab
	let bc = cross(c, b)
	
	let lenBC = length(bc)
	
	let cosB = dot(ba, bc) / (lenAB * lenBC)
	let B = acos(cosB)
	
	let ca = -ac //cross(a, c) // = -ac
	let cb = -bc //cross(b, c) // = -bc
	
	let cosC = dot(ca, cb) / (lenAC * lenBC)
	let C = acos(cosC)
	
	return (A, B, C)
}

//Assumes triangles on unit sphere
public func areaOfSphericalTriangle(a: SIMD3<Double>, b: SIMD3<Double>, c: SIMD3<Double>) -> Double {
	let angles = surfacePointsToRadians(a: a, b: b, c: c)
	
	let E = angles.A + angles.B + angles.C - Double.pi //Shperical excess
	
	return abs(E)
//	return windingOrder(p0: a, p1: b, p2: c, referenceDirection: a) == .Clockwise ? E : -E
}

public func barycentricToCartesian(p1: SIMD4<Double>, p2: SIMD4<Double>, p3: SIMD4<Double>, w1: Double, w2: Double, w3: Double) -> SIMD3<Double> {
	return  SIMD3<Double>(x: w1 * p1.x + w2 * p2.x + w3 * p3.x,
					y: w1 * p1.y + w2 * p2.y + w3 * p3.y,
					z: w1 * p1.z + w2 * p2.z + w3 * p3.z)
}

public func createRotationMatrix(angle: Double, axis a: SIMD4<Double>) -> double4x4 {
	let cos_ang = cos(angle)
	let sin_ang = sin(angle)
	let one_minus_cos = (1 - cos_ang)
	
	let col_0 = SIMD4<Double>(cos_ang + a.x * a.x * one_minus_cos, a.y * a.x * one_minus_cos + a.z * sin_ang, a.z * a.x * one_minus_cos - a.y * sin_ang, 0.0)
	let col_1 = SIMD4<Double>(a.x * a.y * one_minus_cos - a.z * sin_ang, cos_ang + a.y * a.y * one_minus_cos, a.z * a.y * one_minus_cos + a.x * sin_ang, 0.0)
	let col_2 = SIMD4<Double>(a.x * a.z * one_minus_cos + a.y * sin_ang, a.y * a.z * one_minus_cos - a.x * sin_ang, cos_ang + a.z * a.z * one_minus_cos, 0.0)
	let col_3 = SIMD4<Double>(0.0, 0.0, 0.0, 1.0) //w might need to be 2 - cos_ang
	
	return double4x4(columns: (col_0, col_1, col_2, col_3))
}

/*
public extension double4 {
	init(_ pre: double3, _ post: Double) {
		self.init(pre.x, pre.y, pre.y, post)
	}
}
 */

public extension SIMD4 where Scalar == Float {
	init(_ v: SIMD4<Double>) {
		self = SIMD4<Float>(Float(v.x), Float(v.y), Float(v.z), Float(v.w))
	}
}

public extension float4x4 {
	init(_ m: double4x4) {
		self = float4x4(SIMD4<Float>(m.columns.0), SIMD4<Float>(m.columns.1), SIMD4<Float>(m.columns.2), SIMD4<Float>(m.columns.3))
	}
}

public func radians<T: FloatingPoint>(fromDegrees degrees: T) -> T {
	return (degrees / 180) * T.pi
}

public func degrees<T: FloatingPoint>(fromRadians radians: T) -> T {
	return (radians / T.pi) * 180
}
