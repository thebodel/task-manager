import SwiftUI

// MARK: - Models

enum RepeatOption: String, CaseIterable, Identifiable {
    case never = "Never"
    case hourly = "Hourly"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
    case quarterly = "Every 3 Months"
    case yearly = "Yearly"

    var id: String { rawValue }
}

enum EarlyReminderOption: String, CaseIterable, Identifiable {
    case none = "None"
    case fiveMinutes = "5 minutes before"
    case fifteenMinutes = "15 minutes before"
    case thirtyMinutes = "30 minutes before"
    case oneHour = "1 hour before"
    case twoHours = "2 hours before"
    case oneDay = "1 day before"
    case twoDays = "2 days before"
    case oneWeek = "1 week before"
    case oneMonth = "1 month before"
    case custom = "Custom"

    var id: String { rawValue }
}

// MARK: - Generic Picker Row

struct PickerRow<Option: CaseIterable & Identifiable & RawRepresentable>: View
where Option.RawValue == String, Option.AllCases: RandomAccessCollection {

    let icon: String
    let title: String
    @Binding var selection: Option

    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Text(selection.rawValue)
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPicker) {
            PickerPopoverContent(selection: $selection, isPresented: $showPicker)
        }
    }
}

// MARK: - Popover Content

struct PickerPopoverContent<Option: CaseIterable & Identifiable & RawRepresentable>: View
where Option.RawValue == String, Option.AllCases: RandomAccessCollection {

    @Binding var selection: Option
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(Option.allCases)) { option in
                Button {
                    selection = option
                    isPresented = false
                } label: {
                    HStack {
                        if selection.id == option.id {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .frame(width: 20)
                        } else {
                            Color.clear.frame(width: 20)
                        }

                        Text(option.rawValue)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if option.rawValue == "1 month before" {
                    Divider()
                        .padding(.leading, 36)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(minWidth: 220)
    }
}

// MARK: - Main View

struct RepeatAndReminderView: View {

    @State private var repeatOption: RepeatOption = .never
    @State private var earlyReminder: EarlyReminderOption = .none

    var body: some View {
        List {
            PickerRow(
                icon: "repeat",
                title: "Repeat",
                selection: $repeatOption
            )

            PickerRow(
                icon: "bell",
                title: "Early Reminder",
                selection: $earlyReminder
            )
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#else
        .listStyle(.inset)
#endif
    }
}

// MARK: - Preview

#Preview {
    RepeatAndReminderView()
}
