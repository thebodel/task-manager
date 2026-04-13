import SwiftUI

struct LoginScreen: View {
    @State private var selectedTab = 0
    @State private var errorMessage: String?

    @State private var goToProjects = false
    @State private var loggedUserId = 0
    @State private var hasAppearedOnce = false

    @State private var newUser = UserCreate(
        login: "",
        password: ""
    )

    var body: some View {
        NavigationStack {
            ZStack {

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
                            .onChange(of: newUser.login) { _, _ in
                                errorMessage = nil
                            }

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
                            .onChange(of: newUser.password) { _, _ in
                                errorMessage = nil
                            }

                        Button("Submit") {
                            if selectedTab == 1 {
                                Task {
                                    if let response = await createUser(form: newUser) {
                                        loggedUserId = response.userId
                                        goToProjects = true
                                    }
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
                    .onChange(of: selectedTab) { _, _ in
                        errorMessage = nil
                    }
                    .padding()
                    .frame(maxWidth: 320)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                }
            }
            .navigationDestination(isPresented: $goToProjects) {
                ProjectsListView(userId: loggedUserId)
            }
            .onChange(of: goToProjects) { _, isPresented in
                if hasAppearedOnce && !isPresented {
                    errorMessage = nil
                    newUser.login = ""
                    newUser.password = ""
                }
                if !hasAppearedOnce {
                    hasAppearedOnce = true
                }
            }
     }
    }
    private func createUser(form: UserCreate) async -> LoginResponse? {
        do {
            return try await APIService.shared.createUser(form: form)
        } catch {
            errorMessage = error.localizedDescription
            return nil
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
