import SwiftUI

struct LoginScreen: View {
    @State private var selectedTab = 0
    @State private var errorMessage: String?

    @State private var goToProjects = false
    @State private var loggedUserId = 0

    @State private var newUser = UserCreate(
        login: "",
        password: ""
    )

    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    Color.gray.opacity(0.2)
                        .ignoresSafeArea()
                }
                .blur(radius: 4)

                ZStack {
                    Color.gray.opacity(0.04)
                        .ignoresSafeArea()

                    VStack(alignment: .leading) {
                        GlassSwitcher(selectedTab: $selectedTab)

                        TextField("login", text: $newUser.login)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.gray.opacity(0.15))
                            )
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.top, 5)

                        SecureField("password", text: $newUser.password)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.gray.opacity(0.15))
                            )
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.top, 5)

                        Button("Submit") {
                            if selectedTab == 1 {
                                Task {
                                    await createUser(form: newUser)
                                }
                            } else if selectedTab == 0 {
                                Task {
                                    if let response = await loginUser(form: newUser) {
                                        loggedUserId = response.userId
                                        goToProjects = true
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white.opacity(0.95))
                        .buttonStyle(.plain)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.top, 5)
                        .disabled(
                            newUser.login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            newUser.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .frame(width: 280)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                }
            }
            .navigationDestination(isPresented: $goToProjects) {
                ProjectsListView(userId: loggedUserId)
            }
        }
    }

    private func createUser(form: UserCreate) async {
        do {
            try await APIService.shared.createUser(form: form)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loginUser(form: UserCreate) async -> LoginResponse? {
        do {
            return try await APIService.shared.loginUser(form: form)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

#Preview {
    LoginScreen()
}
