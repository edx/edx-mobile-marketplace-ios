//
//  TrackCardView.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/2/25.
//

import SwiftUI
import Theme

struct TrackCardView: View {
    var heading: String
    var subheading: String
    var paragraphs: [String]
    var isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(width: 24, height: 24)
                .padding(2)

            VStack(alignment: .leading, spacing: .zero) {
                // Card Header
                VStack(alignment: .leading, spacing: .zero) {
                    Text(heading)
                        .font(Theme.Fonts.titleMedium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !subheading.isEmpty {
                        Text(subheading)
                            .font(Theme.Fonts.bodyLarge)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .foregroundColor(Theme.Colors.textPrimary)

                // Card Section
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(paragraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .font(Theme.Fonts.bodyMedium)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 16)

                Spacer(minLength: 0)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 24)
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isSelected ? Theme.Colors.accentColor : Theme.Colors.datesSectionStroke,
                    lineWidth: 2
                )
        )
        .background(Theme.Colors.datesSectionBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 6)
        )
        .if(isSelected) { view in
            view
                .shadow(color: Theme.Colors.shadowColor, radius: 4, y: 1)
                .shadow(color: Theme.Colors.shadowColor, radius: 2, y: 1)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        TrackCardView(
            heading: "Earn a certificate for $99",
            subheading: "",
            paragraphs: [
                "Get access to all graded course activities and course materials, even after the course ends.",
                "Earn a verified certificate of completion."
            ],
            isSelected: true
        )

        TrackCardView(
            heading: "Access this course",
            subheading: "Access expires January 1st",
            paragraphs: [
                "Limited access to non-graded activities and course material."
            ],
            isSelected: false
        )
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(24)
}
#endif
