//
//  CreateBotView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI


class CreateBotViewModel: ObservableObject {
    @Published var botName = ""
    @Published var botDescription = ""
    @Published var publicId = ""
    @Published var knowledgeBase: [String] = []
    @Published var selectedIcon = "person.fill"
    
    let icons = ["person.fill", "brain.head.profile", "desktopcomputer", "fork.knife", "atom", "cross.case.fill", "leaf.fill"]
    
    func isFormValid() -> Bool {
        !botName.isEmpty && !botDescription.isEmpty && !publicId.isEmpty
    }
    
    func submitCreation() async -> Bool {
        guard isFormValid() else { return false }
        
        let newBot = BotCreable(
            name: botName,
            description: botDescription,
            publicId: publicId,
            knowledge: knowledgeBase,
            icon: selectedIcon
        )
        
        do {
            try await BackendService.shared.createBot(bot: newBot)
            // Here you would typically send the newBot to your data store or API
            print("New bot created: \(newBot)")
            
            // Return true to indicate successful creation
            return true
        } catch {
            return false
        }
        
    }
}

import SwiftUI

struct CreateBotView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateBotViewModel()
    @State private var editingKnowledge: String?
    @State private var editingIndex: Int?
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(viewModel.selectedIcon == icon ? .green : .primary)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(viewModel.selectedIcon == icon ? Color.green.opacity(0.2) : Color.clear)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Bot Information")) {
                    TextField("Bot Name", text: $viewModel.botName)
                    TextField("Description", text: $viewModel.botDescription)
                    TextField("Public Identifier", text: $viewModel.publicId)
                }
                
                Section(header: Text("Knowledge Base")) {
                    ForEach(viewModel.knowledgeBase.indices, id: \.self) { index in
                        if editingIndex == index {
                            TextField("Edit knowledge", text: Binding(
                                get: { viewModel.knowledgeBase[index] },
                                set: { viewModel.knowledgeBase[index] = $0 }
                            ))
                            .onSubmit {
                                editingIndex = nil
                            }
                        } else {
                            Text(viewModel.knowledgeBase[index])
                                .onTapGesture {
                                    editingIndex = index
                                }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.knowledgeBase.remove(atOffsets: indexSet)
                        if let firstIndex = indexSet.first, editingIndex == firstIndex {
                            editingIndex = nil
                        }
                    }
                    
                    HStack {
                        TextField("Add knowledge", text: .constant(""))
                            .onSubmit {
                                let newKnowledge = "New Knowledge Item"
                                viewModel.knowledgeBase.append(newKnowledge)
                                editingIndex = viewModel.knowledgeBase.count - 1
                            }
                        Button(action: {
                            let newKnowledge = "New Knowledge Item"
                            viewModel.knowledgeBase.append(newKnowledge)
                            editingIndex = viewModel.knowledgeBase.count - 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        submitBot()
                    }) {
                        HStack {
                            Spacer()
                            Text("Submit")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isFormValid() || isSubmitting)
                    .opacity(viewModel.isFormValid() && !isSubmitting ? 1 : 0.6)
                }
            }
            .navigationTitle("Create Bot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        submitBot()
                    }
                    .disabled(!viewModel.isFormValid() || isSubmitting)
                }
            }
        }
        .preferredColorScheme(.dark)
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

struct CreateBotView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBotView()
    }
}
