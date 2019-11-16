//
//  Signal.swift
//  JSMath
//
//  Created by Jon Sturk on 2017-06-28.
//  Copyright © 2017 Jon Sturk. All rights reserved.
//

import Foundation

public func sawtoothD<T>(amplitude a: Double = 1.0, frequency f: Double = 1.0, interval: T, iterations k: Int) -> [Double] where T: Sequence, T.Element == Double {
	//Using formula found at https://en.wikipedia.org/wiki/Sawtooth_wave
	let gen = {(time: Double) -> Double in
		let inner = {(f_i: Double, k_i: Int, t: Double) -> Double in
			let p = (k_i % 2 == 0) ? 1.0 : -1.0
			return p * ((sin(2 * Double.pi * Double(k_i) * f_i * t)) / Double(k_i))
		}
		let iter_sum = (1 ..< k).map{inner(f, $0, time)}.reduce(0, +)
		
		return (a / 2.0) - ((a / Double.pi) * iter_sum)
	}
	return interval.map{gen($0)}
}
