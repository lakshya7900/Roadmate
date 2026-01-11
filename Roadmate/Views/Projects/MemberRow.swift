import SwiftUI

struct MemberRow: View {
    let member: ProjectMember
    let isOwner: Bool
    let onRoleChange: (ProjectRole) -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(member.username)
                        .font(.headline)

                    if isOwner {
                        Text("Owner")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.purple.opacity(0.15), in: Capsule())
                            .foregroundStyle(.purple)
                    }
                }

                Text(member.role.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !isOwner {
                Picker("", selection: Binding(
                    get: { member.role },
                    set: { onRoleChange($0) }
                )) {
                    ForEach(ProjectRole.allCases.filter { $0 != .owner }) { r in
                        Text(r.label).tag(r)
                    }
                }
                .labelsHidden()
                .frame(width: 160)
            }

            if let onDelete, !isOwner {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Remove member")
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(roleColor.opacity(0.18))
                .frame(width: 36, height: 36)

            Text(initials(member.username))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(roleColor)
        }
        .accessibilityHidden(true)
    }

    private var roleColor: Color {
        switch member.role {
        case .owner: return .purple
        case .frontend: return .blue
        case .backend: return .green
        case .fullstack: return .teal
        case .pm: return .orange
        case .qa: return .pink
        }
    }

    private func initials(_ username: String) -> String {
        let parts = username.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(username.prefix(2)).uppercased()
    }
}
