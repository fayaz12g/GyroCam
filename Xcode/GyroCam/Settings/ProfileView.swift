import SwiftUI
import WishKit

struct ProfileView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var isShowingSaveSuccess: Bool = false
    @State private var isDirty: Bool = false
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case name, email
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeaderView
                
                // Input Fields
                inputFieldsView
                
                // Save Button
                saveButtonView
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(when: cameraManager.useBlurredBackground,
                          accentColor: cameraManager.primaryColor)
        .onAppear {
            name = cameraManager.userName
            email = cameraManager.userEmail
        }
        .onChange(of: name) {_, _ in
            isDirty = true
            isShowingSaveSuccess = false
        }
        .onChange(of: email) {_,  _ in
            isDirty = true
            isShowingSaveSuccess = false
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(cameraManager.accentColor)
                .padding()
                .background(
                    Circle()
                        .fill(Color(colorScheme == .dark ? .systemGray5 : .systemGray6))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.top, 16)
            
            Text("User Profile")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 16) {
            // Name Field
            inputField(
                title: "Name",
                text: $name,
                iconName: "person.fill",
                fieldType: .name
            )
            
            // Email Field
            inputField(
                title: "Email",
                text: $email,
                iconName: "envelope.fill",
                fieldType: .email
            )
        }
    }
    
    private func inputField(title: String, text: Binding<String>, iconName: String, fieldType: FocusField) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(cameraManager.accentColor)
                
                TextField(title, text: text)
                    .focused($focusedField, equals: fieldType)
                    .keyboardType(fieldType == .email ? .emailAddress : .default)
                    .autocapitalization(fieldType == .email ? .none : .words)
                    .disableAutocorrection(fieldType == .email)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(colorScheme == .dark ? .systemGray5 : .systemGray6))
                    .opacity(0.8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cameraManager.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private var saveButtonView: some View {
        Button(action: saveProfile) {
            HStack(spacing: 12) {
                if isShowingSaveSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text("Save")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                cameraManager.accentColor
                    .opacity(isDirty ? 1.0 : 0.2)
            )
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: cameraManager.accentColor.opacity(0.4), radius: 5, x: 0, y: 2)
            .padding(.vertical)
        }
        .disabled(!isDirty)
        .animation(.spring(), value: isShowingSaveSuccess)
    }
    
    // MARK: - Actions
    
    private func saveProfile() {
        // Dismiss keyboard
        focusedField = nil
        
        // Save data
        cameraManager.userName = name
        cameraManager.userEmail = email
        cameraManager.userDevice = UIDevice.modelName
        
        // Update WishKit user info
        WishKit.updateUser(email: email)
        WishKit.updateUser(name: name)
        WishKit.updateUser(customID: UIDevice.modelName)
        
        // Show success animation
        withAnimation {
            isShowingSaveSuccess = true
            isDirty = false
        }
        
        // Hide success animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if !isDirty {
                    isShowingSaveSuccess = false
                }
            }
        }
    }
}
