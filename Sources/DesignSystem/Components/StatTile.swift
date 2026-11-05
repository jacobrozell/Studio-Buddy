import SwiftUI

enum SpokenCount {
    static func phrase(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}

/// Compact stat tile for library and project summaries.
struct StatTile: View {
    let value: String
    let label: String
    var systemImage: String?
    /// Spoken form, so "1" + "Songs" is not read as "1 Songs".
    var spokenLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Brand.accent)
                    .accessibilityHidden(true)
            }
            Text(value)
                .font(DS.Typography.statValue())
                .foregroundStyle(Brand.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(Brand.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.md)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel ?? "\(value) \(label)")
    }
}
