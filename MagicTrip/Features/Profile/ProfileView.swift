import SwiftUI
import UserNotifications

struct ProfileView: View {
    let profile: TripProfile
    var vm: ChecklistViewModel
    @State private var showEdit = false
    @State private var notificationsEnabled = false
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Perfil"))
                        .mtLabel()
                        .foregroundStyle(Color.mtText3)
                    Text(String(localized: "Sua viagem"))
                        .mtLargeTitle()
                        .foregroundStyle(Color.mtText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                // Trip summary card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(String(localized: "Detalhes da viagem"))
                            .mtFont(15, weight: .semibold)
                            .foregroundStyle(Color.mtText)
                        Spacer()
                        Button(String(localized: "Editar")) { showEdit = true }
                            .mtFont(14, weight: .semibold)
                            .foregroundStyle(Color.mtPrimary)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            StatPill(icon: "person.2.fill", label: String(localized: "Viajantes"), value: "\(profile.totalTravelers)")
                            if let dep = profile.departureDate {
                                StatPill(icon: "airplane.departure", label: String(localized: "Saída"), value: dep.tripDayFormatted)
                            }
                            if let days = profile.durationDays {
                                StatPill(icon: "moon.stars", label: String(localized: "Noites"), value: "\(days)")
                            }
                            StatPill(icon: "flag", label: String(localized: "País"), value: profile.country)
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .padding(16)
                .background(Color.mtCard)
                .cornerRadius(.mtCardLg)
                .mtCardShadow()
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Savings tile
                Button {
                    // handled by parent
                } label: {
                    GradientCard {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.18))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "sparkles")
                                    .mtFont(24, weight: .medium)
                                    .foregroundStyle(.white)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(String(localized: "ECONOMIA ESTIMADA"))
                                    .mtFont(12, weight: .medium)
                                    .foregroundStyle(.white.opacity(0.85))
                                Text("≈ \(vm.totalSavedUSD.formatUSD())")
                                    .mtFont(22, weight: .bold).monospacedDigit()
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Settings
                MTGroup(header: String(localized: "Configurações")) {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(Color.mtPrimary)
                            Text(String(localized: "Notificações de prazo"))
                                .mtFont(16)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .tint(Color.mtPrimary)
                    .onChange(of: notificationsEnabled) {
                        if notificationsEnabled {
                            let tasks = vm.resolvedTasks.filter { $0.effectiveDeadlineDays != nil }
                            NotificationScheduler.shared.scheduleAll(for: profile, tasks: tasks)
                        } else {
                            NotificationScheduler.shared.cancelAll()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Appearance
                MTGroup(header: String(localized: "Aparência")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundStyle(Color.mtPrimary)
                            Text(String(localized: "Tema"))
                                .mtFont(16)
                        }
                        Picker(String(localized: "Tema"), selection: $appearanceModeRaw) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.label).tag(mode.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                Spacer().frame(height: 110)
            }
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showEdit) {
            EditProfileFlow(profile: profile, vm: vm) { showEdit = false }
        }
        .task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            notificationsEnabled = settings.authorizationStatus == .authorized
        }
    }
}
