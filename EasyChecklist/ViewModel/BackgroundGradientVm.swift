//
//  BackgroundGradientVm.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 24.10.25.
//

import SwiftUI
import AwesomeSwiftyComponents

@Observable
class BackgroundGradientVm {
	
	private(set) var colors: Array<Color> = []

	private let basePoints: [SIMD2<Float>] = [
		.init(0.00, 0.00), .init(0.25, 0.00), .init(0.50, 0.00), .init(0.75, 0.00), .init(1.00, 0.00),
		.init(0.00, 0.25), .init(0.25, 0.25), .init(0.50, 0.25), .init(0.75, 0.25), .init(1.00, 0.25),
		.init(0.00, 0.50), .init(0.25, 0.50), .init(0.50, 0.50), .init(0.75, 0.50), .init(1.00, 0.50),
		.init(0.00, 0.75), .init(0.25, 0.75), .init(0.50, 0.75), .init(0.75, 0.75), .init(1.00, 0.75),
		.init(0.00, 1.00), .init(0.25, 1.00), .init(0.50, 1.00), .init(0.75, 1.00), .init(1.00, 1.00)
	]
	private let amplitude: Float = 0.15
	private var seeds: [PointSeed] = []
	private var startDate = Date()
	
	init() {
		self.seeds = Self.getSeed(basePoints: basePoints)
		self.colors = Self.getColors(baseColor: SystemDefaults.accentColor)
	}
	
	public func setBackgroundColor(baseColor: AvailableColors) {
		withAnimation {
			self.colors = Self.getColors(baseColor: baseColor)
		}
	}
	
	public func points(at time: Date) -> [SIMD2<Float>] {
		let passedTime: TimeInterval = time.timeIntervalSince(startDate)
		
		return zip(basePoints, seeds).map { base, seed in
			var x: Float = base.x
			var y: Float = base.y
			
			let shouldMoveX = base.x != 0 && base.x != 1
			let shouldMoveY = base.y != 0 && base.y != 1
			
			var edge = base
			if shouldMoveX && shouldMoveY {
				edge = edgeFalloffFor(base: base)
			}
			
			if shouldMoveX {
				let ax = amplitude * edge.x
				let dx = ax * sin(seed.freqX * Float(passedTime) + seed.phaseX)
				x = min(max(base.x + dx, 0), 1)
			}
			
			if shouldMoveY {
				let ay = amplitude * edge.y
				let dy = ay * cos(seed.freqY * Float(passedTime) + seed.phaseY)
				y = min(max(base.y + dy, 0), 1)
			}
			return SIMD2<Float>(x, y)
		}
	}
	
	private func edgeFalloffFor(base: SIMD2<Float>) -> SIMD2<Float> {
		let fx = min(base.x, 1 - base.x) / 0.5
		let fy = min(base.y, 1 - base.y) / 0.5
		
		return .init(
			max(0.25, min(1.0, fx)),
			max(0.25, min(1.0, fy))
		)
	}
	
	// MARK: - init
	
	private static func getSeed(basePoints: [SIMD2<Float>]) -> [PointSeed] {
		return basePoints.map { base in
			PointSeed.random(for: base)
		}
	}
	
	private static func getColors(baseColor: AvailableColors) -> [Color] {
		let availableColors: Set<Color> = [baseColor.SwiftUIColor, baseColor.adjacentColor1, baseColor.adjacentColor2]
		var colors: Array<Color> = []
		
		for _ in 0..<25 {
			colors.append(availableColors.randomElement()!)
		}
		
		return colors
	}
}

fileprivate struct PointSeed: Hashable {
	let phaseX: Float
	let phaseY: Float
	let freqX: Float
	let freqY: Float
	
	static func random(for base: SIMD2<Float>) -> PointSeed {
		// Slightly vary frequencies so points don’t sync up
		let baseF: ClosedRange<Float> = 0.25...0.55 // cycles per second-ish
		return .init(
			phaseX: Float.random(in: 0...(2 * .pi)),
			phaseY: Float.random(in: 0...(2 * .pi)),
			freqX: Float.random(in: baseF),
			freqY: Float.random(in: baseF)
		)
	}
}
