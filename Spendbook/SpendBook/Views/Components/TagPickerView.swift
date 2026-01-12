import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Query(sort: \Expense.date, order: .reverse) private var recentExpenses: [Expense]
    @State private var searchText = ""
    @State private var currentParent: Tag?
    @State private var showInactiveTags = false
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewTagSheet = false
    @State private var newTagName = ""
    @State private var selectedColorHex = "#89B4FA"

    private let smartTagService = SmartTagService()

    /// Smart suggestions based on frequency, recency, time-of-day, and day-of-week patterns
    var suggestedTags: [Tag] {
        // Only consider last 90 days of expenses for pattern analysis
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let relevantExpenses = recentExpenses.filter { $0.date >= ninetyDaysAgo }
        let activeTags = allTags.filter { $0.isActive }
        return smartTagService.getSuggestedTags(from: activeTags, expenses: relevantExpenses)
    }
    
    // Filter tags based on search, hierarchy, and active state
    var filteredTags: [Tag] {
        let tagsToFilter = showInactiveTags ? allTags : allTags.filter { $0.isActive }
        
        if !searchText.isEmpty {
            return tagsToFilter.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return tagsToFilter.filter { $0.parent == currentParent }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.Catppuccin.overlay0)
                TextField("Search tags...", text: $searchText)
                    .foregroundColor(Color.Catppuccin.text)
            }
            .padding()
            .background(Color.Catppuccin.mantle)
            .cornerRadius(12)
            
            // Breadcrumbs / Back button
            if currentParent != nil && searchText.isEmpty {
                Button(action: {
                    withAnimation {
                        currentParent = currentParent?.parent
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(currentParent?.name ?? "Back")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(Color.Catppuccin.blue)
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Smart Suggestions Section (Only show at root level)
                    if currentParent == nil && !suggestedTags.isEmpty && searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggested")
                                .font(.subheadline.bold())
                                .foregroundColor(Color.Catppuccin.subtext0)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(suggestedTags) { tag in
                                    TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        toggleSelection(for: tag)
                                    } onNavigate: {
                                        withAnimation {
                                            currentParent = tag
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Main Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text(searchText.isEmpty ? (currentParent == nil ? "All Categories" : "Sub-tags") : "Search Results")
                            .font(.subheadline.bold())
                            .foregroundColor(Color.Catppuccin.subtext0)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(filteredTags) { tag in
                                TagButton(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag),
                                    showInactive: showInactiveTags
                                ) {
                                    toggleSelection(for: tag)
                                } onNavigate: {
                                    withAnimation {
                                        currentParent = tag
                                    }
                                }
                            }
                            
                            if searchText.isEmpty {
                                Button(action: {
                                    showingNewTagSheet = true
                                    newTagName = ""
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("New")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color.Catppuccin.subtext0)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.Catppuccin.overlay0, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        // Show inactive tags toggle
                        if !showInactiveTags && allTags.contains(where: { !$0.isActive }) {
                            Button(action: {
                                withAnimation {
                                    showInactiveTags = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "eye.slash")
                                    Text("Show inactive tags")
                                }
                                .font(.caption)
                                .foregroundColor(Color.Catppuccin.overlay1)
                                .padding(.top, 8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.Catppuccin.base)
        .sheet(isPresented: $showingNewTagSheet) {
            NewTagSheet(
                parentTag: currentParent,
                tagName: $newTagName,
                selectedColorHex: $selectedColorHex,
                onSave: createNewTag,
                onCancel: { showingNewTagSheet = false }
            )
        }
    }
    
    private func toggleSelection(for tag: Tag) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func createNewTag() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newTag = Tag(name: trimmedName, colorHex: selectedColorHex, parent: currentParent)
        modelContext.insert(newTag)
        
        showingNewTagSheet = false
        newTagName = ""
    }
}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    var showInactive: Bool = false
    let action: () -> Void
    let onNavigate: () -> Void
    
    private var hasChildren: Bool {
        !(tag.children?.isEmpty ?? true)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: action) {
                Text(tag.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Color.Catppuccin.base : Color(hex: tag.colorHex))
                    .opacity(tag.isActive ? 1.0 : 0.5)
                    .padding(.vertical, 8)
                    .padding(.leading, 16)
                    .padding(.trailing, hasChildren ? 8 : 16)
            }
            
            if hasChildren {
                Button(action: onNavigate) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? Color.Catppuccin.base : Color(hex: tag.colorHex))
                        .opacity(tag.isActive ? 1.0 : 0.5)
                        .padding(.trailing, 12)
                        .padding(.vertical, 8)
                }
            }
        }
        .background(
            Capsule()
                .fill(isSelected ? Color(hex: tag.colorHex) : Color.Catppuccin.mantle)
                .opacity(tag.isActive ? 1.0 : 0.5)
        )
        .overlay(
            Capsule()
                .stroke(Color(hex: tag.colorHex), lineWidth: 1)
                .opacity(tag.isActive ? 1.0 : 0.3)
        )
    }
}

struct NewTagSheet: View {
    let parentTag: Tag?
    @Binding var tagName: String
    @Binding var selectedColorHex: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    private let colors: [(name: String, hex: String)] = [
        ("Blue", "#89B4FA"),
        ("Lavender", "#B4BEFE"),
        ("Sapphire", "#74C7EC"),
        ("Mauve", "#CBA6F7"),
        ("Red", "#F38BA8"),
        ("Peach", "#FAB387"),
        ("Green", "#A6E3A1"),
        ("Yellow", "#F9E2AF")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tag Name", text: $tagName)
                        .autocapitalization(.words)
                } header: {
                    Text("Name")
                } footer: {
                    if let parent = parentTag {
                        Text("Will be created under: \(parent.name)")
                    }
                }
                
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(colors, id: \.hex) { color in
                            Button(action: {
                                selectedColorHex = color.hex
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color.hex))
                                        .frame(width: 40, height: 40)
                                    
                                    if selectedColorHex == color.hex {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
