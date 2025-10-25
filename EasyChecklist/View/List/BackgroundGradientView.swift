//
//  BackgroundGradientView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 23.10.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct BackgroundGradientView: View {
	
	let vm: BackgroundGradientVm
	
    var body: some View {
		TimelineView(.animation) { context in
			MeshGradient(
				width: 5,
				height: 5,
				points: vm.points(at: context.date),
				colors: vm.colors,
				smoothsColors: false
			)
			.ignoresSafeArea(edges: .all)
			#if os(iOS)
			.overlay(Color(.systemBackground).opacity(0.5))
			#else
			.overlay(Color(.windowBackgroundColor).opacity(0.5))
			#endif
		}
    }
}
#Preview {
	BackgroundGradientView(vm: BackgroundGradientVm(baseColor: AvailableColors.blue))
}
