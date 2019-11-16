//
//  ode.swift
//  JSMath
//
//  Created by Jon Sturk on 2018-08-29.
//  Copyright © 2018 Jon Sturk. All rights reserved.
//

import Foundation
import Accelerate

public func rk4_r<T: FloatingPoint>(_ dx: T, x: T, y: T, f: (T, T) -> T) -> T {
	let k1 = dx * f(x, y)
	let k2 = dx * f(x + dx / 2, y + k1 / 2)
	let k3 = dx * f(x + dx / 2, y + k2 / 2)
	let k4 = dx * f(x + dx, y + k3)
	
	let tmp = (k1 + 2 * k2 + 2 * k3 + k4)
	
	return y + tmp / 6
}

public func rk4<T: FloatingPoint>(tspan: (start: T, end: T), y0: T, step h: T, derivateFunction f: (T, T) -> T) -> (t: [T], y: [T])  {
	var t = tspan.start
	var y = y0
	
	var t_out = [T]()
	var y_out = [T]()
	
	while t < tspan.end {
		t_out.append(t)
		y_out.append(y)
		
		y = rk4_r(h, x: t, y: y, f: f)
		t += h
	}
	
	return (t_out,y_out)
}

public func heun<T: FloatingPoint>(tspan: (start: T, end: T), y0: T, step: T, derivateFunction f: (T, T) -> T) -> (t: [T], y: [T]) {
	let tol: T = (1e-6 as! T)
	let maxIter = 100
	
	var t = tspan.start
	var y = y0
	
	var t_out = [T]()
	var y_out = [T]()
	
	var h = step
	
	while t < tspan.end {
		h = min(h, tspan.end - t)
		t_out.append(t)
		y_out.append(y)
		
		let t1 = t
		let y1 = y
		
		let f1 = f(t1, y1)
		var y2 = y1 + f1 * h
		let t2 = t1 + h
		var err = tol + 1
		var iter = 0
		
		while err > tol, iter < maxIter {
			let y2p = y2
			let f2 = f(t2, y2p)
			let favg = (f1 + f2) / (2.0 as! T)
			
			y2 = y1 + favg * h
			
			err = abs((y2 - y2p) / (y2 + T.leastNonzeroMagnitude));
			iter += 1
		}
		
		t += h
		y = y2
	}
	
	return (t_out, y_out)
}

public struct RKF45 {
	public static let a: [Double] = [0.0, 1.0/4.0, 3.0/8.0, 12.0/13.0, 1.0, 1.0/2.0]
	public static let b: [[Double]] = [[0.0, 0.0, 0.0, 0.0, 0.0],
									   [1.0/4.0, 0, 0, 0, 0],
									   [3.0/32.0, 9.0/32.0, 0, 0, 0],
									   [1932.0/2197.0, -7200.0/2197.0, 7296.0/2197.0, 0, 0],
									   [439.0/216.0, -8, 3680.0/513.0, -845.0/4104.0, 0],
									   [-8.0/27.0, 2, -3544.0/2565.0, 1859.0/4104.0, -11.0/40.0]]
	public static let c4: [Double] = [25.0/216.0, 0, 1408.0/2565.0, 2197.0/4104.0, -1.0/5.0, 0]
	public static let c5: [Double] = [16.0/135.0, 0, 6656.0/12825.0, 28561.0/56430.0, -9.0/50.0, 2.0/55.0]
	public static let eps: Double = 2.2204e-16
}

fileprivate func * (lhs: Double, rhs: [Double]) -> [Double] {
	return rhs.map{lhs * $0}
}

fileprivate func + (lhs: [Double], rhs: [Double]) -> [Double] {
	assert(lhs.count == rhs.count)
	return Array(zip(lhs, rhs).map{$0 + $1})
}

public func rkf45(tspan: (start: Double, end: Double), y0: [Double], tolerance tol: Double, derivateFunction f: (Double, [Double]) -> [Double]) -> (t: [Double], y: [[Double]]) {
	var t = tspan.start
	var y = y0

	var t_out = [Double]()
	var y_out = [[Double]]()

	var h = (tspan.end - tspan.start) / 100;
	let hmin = 16 * RKF45.eps

	let a = RKF45.a
	let b = RKF45.b
	let c = RKF45.c5

	let cdiff = zip(RKF45.c4, RKF45.c5).map{$0 - $1}

	t_out.append(t)
	y_out.append(y)
	
	//All these temp variables are ugly as F, but the compiler couldn't handle longer expressions. WTF, compiler?
	while t < tspan.end {
		let k0 = f(t + a[0] * h, y)
		let ytmp0 = (b[1][0] * k0)
		let k1 = f(t + a[1] * h, y + h * ytmp0)
		let ytmp1 = ((b[2][0] * k0) + (b[2][1] * k1))
		let k2 = f(t + a[2] * h, y + h * ytmp1)
		let ytmp2 = ((b[3][0] * k0) + (b[3][1] * k1) + (b[3][2] * k2))
		let k3 = f(t + a[3] * h, y + h * ytmp2)
		let ytmp3_1: [Double] = (b[4][0] * k0) + (b[4][1] * k1)
		let ytmp3_2: [Double] = (b[4][2] * k2) + (b[4][3] * k3)
		let k4 = f(t + a[4] * h, y + h * (ytmp3_1 + ytmp3_2))
		let ytmp4_1: [Double] = (b[5][0] * k0) + (b[5][1] * k1)
		let ytmp4_2: [Double] = (b[5][2] * k2) + (b[5][3] * k3) + (b[5][4] * k4)
		let k5 = f(t + a[5] * h, y + h * (ytmp4_1 + ytmp4_2))

		let ctmp_1: [Double] = cdiff[0] * k0 + cdiff[1] * k1 + cdiff[2] * k2
		let ctmp_2: [Double] = cdiff[3] * k3 + cdiff[4] * k4 + cdiff[5] * k5
		let err = (h * (ctmp_1 + ctmp_2)).map{abs($0)}
		let maxError = err.max() ?? 0.0
		let y_max = y.map{abs($0)}.max() ?? 0.0
		let te_allowed = tol * max(y_max, 1)
		let delta = pow(te_allowed / (maxError + RKF45.eps), 0.2)
		
		if maxError <= te_allowed {
			h = min(h, tspan.end - t)
			t += h
			y = y + (h * (c[0] * k0 + c[1] * k1 + c[2] * k2 + c[3] * k3 + c[4] * k4 + c[5] * k5))
			
			t_out.append(t)
			y_out.append(y)
		}

		h = min(delta * h, 4 * h);
		if h < hmin {
			fatalError("Step size fell below its minimum allowable value")
		}
	}
	return (t_out, y_out)
}

public func rkf45(tspan: (start: Double, end: Double), y0: Double, tolerance tol: Double, derivateFunction f: (Double, Double) -> Double) -> (t: [Double], y: [Double]) {
	
	var t = tspan.start
	var y = y0
	
	var t_out = [Double]()
	var y_out = [Double]()
	
	var h = (tspan.end - tspan.start) / 100;
	let hmin = 16 * RKF45.eps
	
	let a = RKF45.a
	let b = RKF45.b
	let c = RKF45.c5
	
	let cdiff: [Double] = zip(RKF45.c4, RKF45.c5).map{$0 - $1}
	
	var mulOut = [Double](repeating: 0, count: 6)
	var k = [Double](repeating: 0, count: 6)
	while t < tspan.end {
		var ytmp = [Double](repeating: 0, count: 5)
		var ysum = 0.0
		k[0] = f(t + a[0] * h, y)
		k[1] = f(t + a[1] * h, y + h * (b[1][0] * k[0]))
		k[2] = f(t + a[2] * h, y + h * ((b[2][0] * k[0]) + (b[2][1] * k[1])))
		vDSP_vmulD(b[3], 1, &k, 1, &ytmp, 1, 3)
		vDSP_sveD(&ytmp, 1, &ysum, 3)
		k[3] = f(t + a[3] * h, y + h * ysum)
		vDSP_vmulD(b[4], 1, &k, 1, &ytmp, 1, 4)
		vDSP_sveD(&ytmp, 1, &ysum, 4)
		k[4] = f(t + a[4] * h, y + h * ysum)
		vDSP_vmulD(b[5], 1, &k, 1, &ytmp, 1, 5)
		vDSP_sveD(&ytmp, 1, &ysum, 5)
		k[5] = f(t + a[5] * h, y + h * ysum)
		
		vDSP_vmulD(cdiff, 1, &k, 1, &mulOut, 1, 6)
		vDSP_sveD(&mulOut, 1, &ysum, 6)
		let err = abs(h * ysum)
		let y_max = abs(y)
		let te_allowed = tol * max(y_max, 1)
		let delta = pow(te_allowed / (err + RKF45.eps), 0.2)
		
		if err <= te_allowed {
			t_out.append(t)
			y_out.append(y)
			
			h = min(h, tspan.end - t)
			t += h
			vDSP_vmulD(c, 1, &k, 1, &mulOut, 1, 6)
			vDSP_sveD(&mulOut, 1, &ysum, 6)
			y += h * ysum
		}
		
		h = min(delta * h, 4 * h);
		if h < hmin {
			fatalError("Step size fell below its minimum allowable value")
		}
	}
	return (t_out, y_out)
}
