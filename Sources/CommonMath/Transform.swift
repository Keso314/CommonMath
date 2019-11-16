//
//  Transform.swift
//  JSMath
//
//  Created by Jon Sturk on 2017-06-28.
//  Copyright © 2017 Jon Sturk. All rights reserved.
//

import Accelerate
import Foundation
import simd

public protocol JSDomainTransformerD {
	
}

public extension JSDomainTransformerD {
	func interleave(real: [Double], imag: [Double]) -> [Double] {
		//Assumes real and imag length equal
		var r = real
		var i = imag
		let n = real.count //also equal to imag.count
		var split = DSPDoubleSplitComplex(realp: &r, imagp: &i)
		var out = [Double](repeating: 0.0, count: 2 * n)
		withUnsafeMutablePointer(to: &out[0]) {(unsafe) -> () in
			unsafe.withMemoryRebound(to: DSPDoubleComplex.self, capacity: n) {(rebound) -> () in
				vDSP_ztocD(&split, 1, rebound, 2, UInt(n))
			}
		}
		return out
	}
	
	func deinterleave(interleaved data: [Double]) -> (real: [Double], imag: [Double]) {
		//Assumes length of data is even
		let n = data.count / 2
		var real_out = [Double](repeating: 0.0, count: n)
		var imag_out = [Double](repeating: 0.0, count: n)
		
		var tmp = data
		var splitComplex = DSPDoubleSplitComplex(realp: &real_out, imagp: &imag_out)
		withUnsafePointer(to: &tmp[0]) {(ud) -> () in
			ud.withMemoryRebound(to: DSPDoubleComplex.self, capacity: n) {
				vDSP_ctozD($0, 2, &splitComplex, 1, UInt(n))
			}
		}
		return (real_out, imag_out)
	}
}

public class JSHilbertD: JSDomainTransformerD {
	var inverseSetup: vDSP_DFT_SetupD
	var forwardSetup: vDSP_DFT_SetupD
	
	public init(previousSetup ps: vDSP_DFT_SetupD? = nil, count: UInt) {
		guard let f = vDSP_DFT_zrop_CreateSetupD(ps, count, .FORWARD) else {
			fatalError()
		}
		forwardSetup = f
		
		guard let s = vDSP_DFT_zop_CreateSetupD(f, count, .INVERSE) else { //Inverse should include (zeroed) reflection frequencies
			fatalError()
		}
		inverseSetup = s
		
	}
	
	public func transform(data: [Double]) -> [Double] {
		let splitData = deinterleave(interleaved: data)
		let n = data.count
		let n_2 = n / 2
		var real_fwd = Array<Double>(repeating: 0.0, count: n) //Include reflection frequencies set to 0
		var imag_fwd = Array<Double>(repeating: 0.0, count: n)
		
		vDSP_DFT_ExecuteD(forwardSetup, splitData.real, splitData.imag, &real_fwd, &imag_fwd)
		real_fwd[0] *= 0.5
		real_fwd[n_2] = imag_fwd[0] * 0.5
		imag_fwd[0] = 0.0
		
		print(imag_fwd)
		
		var real_hilbert = Array<Double>(repeating: 0.0, count: n)
		var imag_hilbert = Array<Double>(repeating: 0.0, count: n)
		
		vDSP_DFT_ExecuteD(inverseSetup, real_fwd, imag_fwd, &real_hilbert, &imag_hilbert)
		var mod = 1.0 / Double(n)
		//vDSP_vsmulD(real_hilbert, 1, &mod, &real_hilbert, 1, UInt(n))
		vDSP_vsmulD(imag_hilbert, 1, &mod, &imag_hilbert, 1, UInt(n))
		
		//return interleave(real: real_hilbert, imag: imag_hilbert)
		
		return imag_hilbert
	}
}

public class JSDFTD: JSDomainTransformerD {
	var setup: vDSP_DFT_SetupD
	var direction: vDSP_DFT_Direction {
		didSet {
			reset()
		}
	}
	public var count: UInt {
		didSet {
			if count != oldValue {
				reset()
			}
		}
	}
	
	public init(previousSetup ps: vDSP_DFT_SetupD? = nil, count: UInt, direction: vDSP_DFT_Direction) {
		guard let s = vDSP_DFT_zrop_CreateSetupD(ps, count, direction) else {
			fatalError()
		}
		setup = s
		self.direction = direction
		self.count = count
	}
	
	deinit {
		vDSP_DFT_DestroySetupD(setup)
	}
	
	public func reset() {
		guard let s = vDSP_DFT_zrop_CreateSetupD(setup, count, direction) else {
			fatalError()
		}
		vDSP_DFT_DestroySetupD(setup)
		setup = s
	}
	
	public func realToSplitComplex(inputData: [Double], adjust: Bool = false) -> (real: [Double], imag: [Double]) {
		let dd = deinterleave(interleaved: inputData)
		let mod: Double? = adjust ? 2.0 : nil
		return execute(realIn: dd.real, imagIn: dd.imag, outputCount: inputData.count / 2, scale: mod)
	}
	
	public func complexToReal(realIn r: [Double], imagIn i: [Double], adjust: Bool = false) -> [Double] {
		let mod = adjust ? Double(r.count) : nil
		let res = execute(realIn: r, imagIn: i, outputCount: r.count / 2, scale: mod)
		///return zip(res.real, res.imag).flatMap{[$0.0, $0.1]}
		return interleave(real: res.real, imag: res.imag)
	}
	
	internal func execute(realIn: [Double], imagIn: [Double], outputCount c: Int, scale: Double? = nil) -> (real: [Double], imag: [Double]) {
		var real_out = Array<Double>(repeating: 0.0, count: c)
		var imag_out = Array<Double>(repeating: 0.0, count: c)
		
		vDSP_DFT_ExecuteD(setup, realIn, imagIn, &real_out, &imag_out)
		
		if scale != nil {
			var mod = 1.0 / scale!
			
			vDSP_vsmulD(real_out, 1, &mod, &real_out, 1, UInt(c))
			vDSP_vsmulD(imag_out, 1, &mod, &imag_out, 1, UInt(c))
		}
		return (real_out, imag_out)
	}
	
	public static func expandComplexResult(input: (real: [Double], imag: [Double])) -> (real: [Double], imag: [Double]) {
		let count = input.real.count - 1
		let dc = input.real.first!
		let ny = input.imag.first!
		
		var r = Array(input.real.suffix(from: 1))
		var i = Array(input.imag.suffix(from: 1))
		
		var read = DSPDoubleSplitComplex(realp: &r, imagp: &i)
		
		var cr = [Double](repeating: 0.0, count: count)
		var ci = [Double](repeating: 0.0, count: count)
		
		var write = DSPDoubleSplitComplex(realp: &cr, imagp: &ci)
		
		vDSP_zvconjD(&read, 1, &write, 1, UInt(count))
		
		var rr = [Double]()
		rr.reserveCapacity(2 * count + 2)
		var ri = [Double]()
		ri.reserveCapacity(2 * count + 2)
		
		rr.append(dc)
		rr.append(contentsOf: r)
		rr.append(ny)
		rr.append(contentsOf: cr.reversed())
		
		ri.append(0.0)
		ri.append(contentsOf: i)
		ri.append(0.0)
		ri.append(contentsOf: ci.reversed())
		
		return (rr, ri)
	}
}

