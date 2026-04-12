//
//  GlassSwitcher.swift
//  frontend
//
//  Created by Bohdan on 10/04/2026.
//


import SwiftUI

struct GlassSwitcher: View {
    @Binding var selectedTab: Int
    @Namespace private var selectionAnimation

    var body: some View {
        HStack(spacing: 8) {
            tabButton(title: "Login", index: 0)
            tabButton(title: "Sign Up", index: 1)
        }
        .padding(6)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(selectedTab == index ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(
                    Group {
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.blue.opacity(0.8))
                                .matchedGeometryEffect(id: "selectedTabBackground", in: selectionAnimation)
                                
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

struct AuthView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
           
            GlassSwitcher(selectedTab: $selectedTab)
                .frame(width: 260)
        }
    }
}

#Preview {
    AuthView()
        .frame(width: 500, height: 300)
}
