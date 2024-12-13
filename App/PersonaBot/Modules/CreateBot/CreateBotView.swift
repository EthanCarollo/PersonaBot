//
//  CreateBotView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI

struct CreateBotView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateBotViewModel()
    @State private var editingKnowledge: String?
    @State private var editingIndex: Int?
    @State private var isSubmitting = false
    @State private var newKnowledge = ""
    @State private var isValidPublicId: Bool = true // Added state variable

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    iconSelector
                    
                    botInformationSection
                    
                    instructionSection
                    
                    knowledgeBaseSection
                    
                    submitButton
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Create Bot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.neonGreen)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        submitBot()
                    }
                    .disabled(!viewModel.isFormValid() || isSubmitting)
                    .foregroundColor(viewModel.isFormValid() && !isSubmitting ? .neonGreen : .gray)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var iconSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(viewModel.selectedIcon == icon ? .neonGreen : .primary)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(viewModel.selectedIcon == icon ? Color.neonGreen.opacity(0.2) : Color.clear)
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedIcon = icon
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var botInformationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Bot Information")
                .font(.headline)
                .foregroundColor(.secondary)
            
            CustomTextField(placeholder: "Bot Name", text: $viewModel.botName)
            CustomTextField(placeholder: "Description", text: $viewModel.botDescription)
            
            VStack(alignment: .leading, spacing: 5) {
                CustomTextField(placeholder: "Public Identifier", text: Binding(
                    get: { viewModel.publicId },
                    set: { viewModel.publicId = $0.lowercased().replacingOccurrences(of: " ", with: "") }
                ))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if !viewModel.publicId.isEmpty {
                    if viewModel.isValidPublicId {
                        Text("Valid public identifier")
                            .foregroundColor(.neonGreen)
                            .font(.caption)
                    } else {
                        Text("Public identifier should not contain spaces")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private var instructionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Instruction")
                .font(.headline)
                .foregroundColor(.secondary)
            
            CustomTextField(placeholder: "Enter instruction", text: $viewModel.instruction)
        }
    }
    
    private var knowledgeBaseSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Knowledge Base")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.knowledgeBase.indices, id: \.self) { index in
                if editingIndex == index {
                    CustomTextField(placeholder: "Edit knowledge", text: Binding(
                        get: { viewModel.knowledgeBase[index] },
                        set: { viewModel.knowledgeBase[index] = $0 }
                    ))
                    .onSubmit {
                        editingIndex = nil
                    }
                } else {
                    Text(viewModel.knowledgeBase[index])
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .onTapGesture {
                            editingIndex = index
                        }
                }
            }
            
            HStack {
                CustomTextField(placeholder: "Add knowledge", text: $newKnowledge)
                    .onSubmit {
                        addNewKnowledge()
                    }
                Button(action: addNewKnowledge) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.neonGreen)
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitBot) {
            Text("Submit")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid() && !isSubmitting ? Color.neonGreen : Color.gray)
                .foregroundColor(.black)
                .cornerRadius(10)
        }
        .disabled(!viewModel.isFormValid() || isSubmitting)
    }
    
    private func addNewKnowledge() {
        if !newKnowledge.isEmpty {
            viewModel.knowledgeBase.append(newKnowledge)
            newKnowledge = ""
        }
    }
    
    private func submitBot() {
        guard !isSubmitting else { return }
        isSubmitting = true
        
        Task {
            let result = await viewModel.submitCreation()
            await MainActor.run {
                isSubmitting = false
                if result {
                    dismiss()
                } else {
                    // Handle submission failure (e.g., show an alert)
                }
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
    }
}

struct CreateBotView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBotView()
    }
}

