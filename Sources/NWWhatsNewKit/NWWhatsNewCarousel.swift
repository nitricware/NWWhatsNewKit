//
//  NWWhatsNewCarousel.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 19.11.26.
//

import SwiftUI

struct NWWhatsNewCarousel: View {
    let configuration: NWWhatsNewStyleConfiguration
    let nextLabel: LocalizedStringResource

    @State private var currentID: String?

    private var items: [NWWhatsNewItem] { configuration.items }

    private var currentIndex: Int {
        items.firstIndex { $0.id == currentID } ?? 0
    }

    private var isLastPage: Bool {
        currentIndex >= items.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            configuration.title
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 48)
                .padding(.horizontal, 36)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items) { item in
                        page(for: item)
                            .containerRelativeFrame(.horizontal)
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentID)
            .scrollIndicators(.hidden)

            if items.count > 1 {
                pageIndicator
                    .padding(.vertical, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            buttons
        }
        .onAppear {
            if currentID == nil { currentID = items.first?.id }
        }
    }

    private func page(for item: NWWhatsNewItem) -> some View {
        ScrollView(.vertical) {
            pageContent(for: item)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.automatic)
    }

    private func pageContent(for item: NWWhatsNewItem) -> some View {
        VStack(spacing: 16) {
            if let image = configuration.image(for: item) {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(maxHeight: 420)
                    .accessibilityLabel(configuration.imageDescription(for: item) ?? configuration.title(for: item))
            } else {
                configuration.symbol(for: item)
                    .font(.system(size: 64))
                    .frame(height: 80)
                    .accessibilityHidden(true)
            }

            configuration.title(for: item)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let description = configuration.description(for: item) {
                description
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 36)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, _ in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var buttons: some View {
        if isLastPage {
            configuration.buttons
        } else {
            Button {
                withAnimation {
                    currentID = items[currentIndex + 1].id
                }
            } label: {
                Text(nextLabel)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(.background)
        }
    }
}
