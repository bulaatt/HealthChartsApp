//
//  ChartContainer.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 12.01.2025.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
    
    @ViewBuilder var content: () -> Content
    
    private var titleColor: Color {
        switch context {
        case .steps: .stepCharts
        case .calories: .calorieCharts
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right.circle")
                    .imageScale(.large)
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(titleColor)
            
            Text(subtitle)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
}

#Preview {
    ChartContainer(title: "Title",
                   symbol: "figure.run",
                   subtitle: "Subtitle",
                   context: .calories,
                   isNav: true) {
        Text("Chart is here")
            .frame(minHeight: 150)
    }
}
