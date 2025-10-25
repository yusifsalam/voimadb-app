import SwiftUI

struct HomeView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        Text(user.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    Spacer()

                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("VoimaDB")
        }
    }
}

#Preview {
    let authManager = AuthManager()
    authManager.currentUser = User(
        id: UUID(),
        name: "John Doe",
        email: "john@example.com",
        createdAt: Date(),
        updatedAt: Date()
    )
    return HomeView()
        .environment(authManager)
}
