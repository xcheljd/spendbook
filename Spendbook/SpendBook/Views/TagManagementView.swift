import SwiftUI
import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var showingNewTagSheet = false
    @State private var editingTag: Tag?
    @State private var showingDeleteAlert = false
    @State private var tagToDelete: Tag?
    
    private var activeTags: [Tag] {
        allTags.filter { $0.isActive }
    }
    
    private var inactiveTags: [Tag] {
        allTags.filter { !$0.isActive }
    }
    
    private var rootActiveTags: [Tag] {
        activeTags.filter { $0.parent == nil }
    }
    
    private var rootInactiveTags: [Tag] {
        inactiveTags.filter { $0.parent == nil }
    }
    
    private var missingPresetTags: [String] {
        let presetNames = Set([
            "Food", "Transport", "Entertainment", "Shopping", 
            "Utilities", "Healthcare", "Income"
        ])
        let existingNames = Set(allTags.map { $0.name })
        return Array(presetNames.subtracting(existingNames)).sorted()
    }
    
    var body: some View {
        List {
            // Summary Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(activeTags.count)")
                            .font(.title2.bold())
                            .foregroundColor(Color.Catppuccin.green)
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(inactiveTags.count)")
                            .font(.title2.bold())
                            .foregroundColor(Color.Catppuccin.overlay1)
                        Text("Inactive")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let mostUsed = allTags.max(by: { $0.expenseCount < $1.expenseCount }), mostUsed.expenseCount > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mostUsed.name)
                                .font(.subheadline.bold())
                                .foregroundColor(Color.Catppuccin.text)
                                .lineLimit(1)
                            Text("\(mostUsed.expenseCount) uses")
                                .font(.caption)
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Quick Actions
            Section {
                Button(action: { showingNewTagSheet = true }) {
                    Label("New Custom Tag", systemImage: "plus.circle.fill")
                        .foregroundColor(Color.Catppuccin.blue)
                }
                
                if !missingPresetTags.isEmpty {
                    Button(action: addMissingPresets) {
                        Label("Add Missing Presets (\(missingPresetTags.count))", systemImage: "tag.fill")
                            .foregroundColor(Color.Catppuccin.green)
                    }
                }
            }
            
            // Active Tags
            if !activeTags.isEmpty {
                Section {
                    ForEach(rootActiveTags) { tag in
                        TagManagementRow(
                            tag: tag,
                            onEdit: { editingTag = tag },
                            onToggleActive: { toggleActive(tag) },
                            onDelete: { confirmDelete(tag) }
                        )
                        
                        // Show children
                        if let children = tag.children, !children.isEmpty {
                            ForEach(children.filter { $0.isActive }) { childTag in
                                TagManagementRow(
                                    tag: childTag,
                                    isChild: true,
                                    onEdit: { editingTag = childTag },
                                    onToggleActive: { toggleActive(childTag) },
                                    onDelete: { confirmDelete(childTag) }
                                )
                            }
                        }
                    }
                } header: {
                    Text("Active Tags (\(activeTags.count))")
                }
            }
            
            // Inactive Tags
            if !inactiveTags.isEmpty {
                Section {
                    ForEach(rootInactiveTags) { tag in
                        TagManagementRow(
                            tag: tag,
                            onEdit: { editingTag = tag },
                            onToggleActive: { toggleActive(tag) },
                            onDelete: { confirmDelete(tag) }
                        )
                        
                        // Show children
                        if let children = tag.children, !children.isEmpty {
                            ForEach(children.filter { !$0.isActive }) { childTag in
                                TagManagementRow(
                                    tag: childTag,
                                    isChild: true,
                                    onEdit: { editingTag = childTag },
                                    onToggleActive: { toggleActive(childTag) },
                                    onDelete: { confirmDelete(childTag) }
                                )
                            }
                        }
                    }
                } header: {
                    Text("Inactive Tags (\(inactiveTags.count))")
                } footer: {
                    Text("Inactive tags are hidden from the picker but remain in historical expenses.")
                        .font(.caption)
                }
            }
            
            // Bulk Actions
            if !allTags.isEmpty {
                Section {
                    Button(action: deactivateAll) {
                        Label("Deactivate All Tags", systemImage: "eye.slash")
                            .foregroundColor(Color.Catppuccin.peach)
                    }
                    
                    Button(action: activateAll) {
                        Label("Activate All Tags", systemImage: "eye")
                            .foregroundColor(Color.Catppuccin.green)
                    }
                    
                    Button(role: .destructive, action: deleteUnused) {
                        Label("Delete Unused Tags", systemImage: "trash")
                    }
                } header: {
                    Text("Bulk Actions")
                } footer: {
                    Text("Unused tags are those with zero expenses.")
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Manage Tags")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNewTagSheet) {
            TagEditSheet(tag: nil, allTags: allTags, modelContext: modelContext)
        }
        .sheet(item: $editingTag) { tag in
            TagEditSheet(tag: tag, allTags: allTags, modelContext: modelContext)
        }
        .alert("Delete Tag?", isPresented: $showingDeleteAlert, presenting: tagToDelete) { tag in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTag(tag)
            }
        } message: { tag in
            if tag.hasExpenses {
                Text("This tag is used in \(tag.expenseCount) expense(s). Deleting it will remove it from those expenses.")
            } else {
                Text("This tag has no expenses. It's safe to delete.")
            }
        }
    }
    
    private func addMissingPresets() {
        // Get existing tag names
        let existingNames = Set(allTags.map { $0.name.lowercased() })
        
        // Define preset tags
        let presets: [(name: String, colorHex: String)] = [
            ("Food", "#F9E2AF"),
            ("Transport", "#89B4FA"),
            ("Entertainment", "#CBA6F7"),
            ("Shopping", "#FAB387"),
            ("Utilities", "#74C7EC"),
            ("Healthcare", "#A6E3A1"),
            ("Income", "#A6E3A1")
        ]
        
        // Create missing tags
        for preset in presets {
            if !existingNames.contains(preset.name.lowercased()) {
                let newTag = Tag(name: preset.name, colorHex: preset.colorHex, parent: nil, isActive: true)
                modelContext.insert(newTag)
            }
        }
        
        try? modelContext.save()
    }
    
    private func toggleActive(_ tag: Tag) {
        withAnimation {
            tag.isActive.toggle()
            try? modelContext.save()
        }
    }
    
    private func confirmDelete(_ tag: Tag) {
        tagToDelete = tag
        showingDeleteAlert = true
    }
    
    private func deleteTag(_ tag: Tag) {
        withAnimation {
            modelContext.delete(tag)
            try? modelContext.save()
        }
    }
    
    private func deactivateAll() {
        for tag in allTags {
            tag.isActive = false
        }
        try? modelContext.save()
    }
    
    private func activateAll() {
        for tag in allTags {
            tag.isActive = true
        }
        try? modelContext.save()
    }
    
    private func deleteUnused() {
        let unusedTags = allTags.filter { !$0.hasExpenses }
        for tag in unusedTags {
            modelContext.delete(tag)
        }
        try? modelContext.save()
    }
}

// MARK: - Tag Management Row

struct TagManagementRow: View {
    let tag: Tag
    var isChild: Bool = false
    let onEdit: () -> Void
    let onToggleActive: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Indentation for child tags
            if isChild {
                Rectangle()
                    .fill(Color.Catppuccin.overlay0)
                    .frame(width: 2, height: 20)
                    .padding(.leading, 8)
            }
            
            // Color indicator
            Circle()
                .fill(Color(hex: tag.colorHex))
                .frame(width: 12, height: 12)
                .opacity(tag.isActive ? 1.0 : 0.3)
            
            // Tag name
            VStack(alignment: .leading, spacing: 2) {
                Text(tag.name)
                    .font(.body)
                    .foregroundColor(tag.isActive ? Color.Catppuccin.text : Color.Catppuccin.overlay1)
                
                if tag.expenseCount > 0 {
                    Text("\(tag.expenseCount) expense\(tag.expenseCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }
            }
            
            Spacer()
            
            // Active indicator
            if !tag.isActive {
                Image(systemName: "eye.slash.fill")
                    .font(.caption)
                    .foregroundColor(Color.Catppuccin.overlay1)
            }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            
            Button(action: onToggleActive) {
                Label(tag.isActive ? "Deactivate" : "Activate", 
                      systemImage: tag.isActive ? "eye.slash" : "eye")
            }
            .tint(tag.isActive ? Color.Catppuccin.peach : Color.Catppuccin.green)
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(Color.Catppuccin.blue)
        }
    }
}

// MARK: - Tag Edit Sheet

struct TagEditSheet: View {
    let tag: Tag?
    let allTags: [Tag]
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var colorHex: String
    @State private var isActive: Bool
    @State private var selectedParent: Tag?
    
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
    
    init(tag: Tag?, allTags: [Tag], modelContext: ModelContext) {
        self.tag = tag
        self.allTags = allTags
        self.modelContext = modelContext
        
        _name = State(initialValue: tag?.name ?? "")
        _colorHex = State(initialValue: tag?.colorHex ?? "#89B4FA")
        _isActive = State(initialValue: tag?.isActive ?? true)
        _selectedParent = State(initialValue: tag?.parent)
    }
    
    private var isEditing: Bool {
        tag != nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var availableParents: [Tag] {
        allTags.filter { potentialParent in
            // Exclude self and children to prevent circular references
            potentialParent != tag && !(tag?.children?.contains(potentialParent) ?? false)
        }.filter { $0.parent == nil } // Only root tags can be parents
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Tag Name", text: $name)
                        .autocapitalization(.words)
                    
                    Toggle("Active", isOn: $isActive)
                        .tint(Color.Catppuccin.blue)
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(colors, id: \.hex) { color in
                            Button(action: {
                                colorHex = color.hex
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color.hex))
                                        .frame(width: 40, height: 40)
                                    
                                    if colorHex == color.hex {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section {
                    Picker("Parent Tag", selection: $selectedParent) {
                        Text("None (Root Tag)").tag(nil as Tag?)
                        ForEach(availableParents) { parent in
                            Text(parent.name).tag(parent as Tag?)
                        }
                    }
                } header: {
                    Text("Organization")
                } footer: {
                    Text("Child tags appear nested under their parent in the tag picker.")
                }
                
                if let tag = tag, tag.hasExpenses {
                    Section("Usage") {
                        HStack {
                            Text("Expenses")
                            Spacer()
                            Text("\(tag.expenseCount)")
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Tag" : "New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        saveTag()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveTag() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let tag = tag {
            // Edit existing tag
            tag.name = trimmedName
            tag.colorHex = colorHex
            tag.isActive = isActive
            tag.parent = selectedParent
        } else {
            // Create new tag
            let newTag = Tag(
                name: trimmedName,
                colorHex: colorHex,
                parent: selectedParent,
                isActive: isActive
            )
            modelContext.insert(newTag)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
