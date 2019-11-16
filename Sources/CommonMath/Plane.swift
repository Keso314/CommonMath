//
//  Plane.swift
//  JSMath
//
//  Created by Jon Sturk on 2017-06-21.
//  Copyright © 2017 Jon Sturk. All rights reserved.
//

import Foundation
import simd

public struct JSPlane<T> where T : SIMDScalar, T : FloatingPoint {
    public let data: SIMD4<T>
    var label: String?
    
    public init(label lbl: String? = nil, a: T, b: T, c: T, d: T) {
        data = SIMD4(a, b, c, d)
        
        self.label = lbl
    }
    
    var a: T {
        return data.x
    }
    
    var b: T {
        return data.y
    }
    
    var c: T {
        return data.z
    }
    
    var d: T {
        return data.w
    }
    
    public init(v0: SIMD3<T>, v1: SIMD3<T>, v2: SIMD3<T>) {
        let v0_1 = v1 - v0
        let v0_2 = v2 - v0
        
        let norm = v0_1.cross(other: v0_2)
        self.init(pointOnPlane: v0, planeNormal: norm)
    }
    
    public init(data: SIMD4<T>) {
        self.data = data
    }
    
    public init(pointOnPlane point: SIMD3<T>, planeNormal norm: SIMD3<T>) {
        let tmp = point.dot(other: norm) * -1
        
        
        data = SIMD4(norm.x, norm.y, norm.z, tmp)
    }
    
    public var normal: SIMD3<T> {
        return data.xyz
    }
    
    public func normalized() -> JSPlane {
        //let len = sqrt(a * a + b * b + c * c)
        
        let len = data.length
        let n = data / SIMD4(len, len, len, len)
        return JSPlane(data: n)
    }
    
    public func isPointInFront(_ point: SIMD3<T>) -> Bool {
        return distanceFromPlane(plane: self, toPoint: point) > 0
    }
    
    public func vectorProjected(_ vec: SIMD3<T>) -> SIMD3<T> {
        return normal.cross(other: vec.cross(other: normal))
    }
}

public typealias JSPlaneF = JSPlane<Float>
public typealias JSPlaneD = JSPlane<Double>

/*
public struct JSPlaneF {
	public let data: float4
	var label: String?
	
	public init(label lbl: String? = nil, a: Float, b: Float, c: Float, d: Float) {
		data = float4(a, b, c, d)
		
		self.label = lbl
	}
	
	var a: Float {
		return data.x
	}
	
	var b: Float {
		return data.y
	}
	
	var c: Float {
		return data.z
	}
	
	var d: Float {
		return data.w
	}
	
	public init(v0: float3, v1: float3, v2: float3) {
		let v0_1 = v1 - v0
		let v0_2 = v2 - v0
		
		let norm = cross(v0_1, v0_2)
		self.init(pointOnPlane: v0, planeNormal: norm)
	}
	
	public init(data: float4) {
		self.data = data
	}
	
	public init(pointOnPlane point: float3, planeNormal norm: float3) {
		let tmp = dot(point, norm) * -1
		
		
		data = float4(norm.x, norm.y, norm.z, tmp)
	}
	
	public var normal: float3 {
		return float3(data.x, data.y, data.z)
	}
	
	public func normalized() -> JSPlaneF {
		//let len = sqrt(a * a + b * b + c * c)
		let len = length(data)
		let n = data / float4(len, len, len, len)
		return JSPlaneF(data: n)
	}
	
	public func isPointInFront(_ point: float3) -> Bool {
		return distanceFromPlane(plane: self, toPoint: point) > 0
	}
	
	public func vectorProjected(_ vec: float3) -> float3 {
		return cross(normal, cross(vec, normal))
	}
}

public struct JSPlaneD {
	public let data: double4
	var label: String?
	
	public init(label lbl: String? = nil, a: Double, b: Double, c: Double, d: Double) {
		data = double4(a, b, c, d)
		
		self.label = lbl
	}
	var a: Double {
		return data.x
	}
	
	var b: Double {
		return data.y
	}
	
	var c: Double {
		return data.z
	}
	
	var d: Double {
		return data.w
	}
	
	public init(v0: double3, v1: double3, v2: double3) {
		let v0_1 = v1 - v0
		let v0_2 = v2 - v0
		
		let norm = cross(v0_1, v0_2)
		self.init(pointOnPlane: v0, planeNormal: norm)
	}
	
	public init(data: double4) {
		self.data = data
	}
	
	public init(pointOnPlane point: double3, planeNormal norm: double3) {
		let tmp = dot(point, norm) * -1
		
		
		data = double4(norm.x, norm.y, norm.z, tmp)
	}
	
	public var normal: double3 {
		return double3(data.x, data.y, data.z)
	}
	
	public func normalized() -> JSPlaneD {
		//let len = sqrt(a * a + b * b + c * c)
		let len = length(data)
		let n = data / double4(len, len, len, len)
		return JSPlaneD(data: n)
	}
	
	public func isPointInFront(_ point: double3) -> Bool {
		return distanceFromPlane(plane: self, toPoint: point) > 0
	}
	
	public func vectorProjected(_ vec: double3) -> double3 {
		return cross(normal, cross(vec, normal))
	}
}
*/
