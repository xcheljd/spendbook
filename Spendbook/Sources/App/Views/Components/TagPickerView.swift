import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var searchText = ""
    @State private var currentParent: Tag?
    
    var frequentlyUsedTags: [Tag] {
        let sorted = allTags.sorted { ($0.expenses?.count ?? 0) > ($1.expenses?.count ?? 0) }
        return Array(sorted.filter { ($0.expenses?.count ?? 0) > 0 }.prefix(5))
    }
    
    // Filter tags based on search and hierarchy
    var filteredTags: [Tag] {
        if !searchText.isEmpty {
            return allTags.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return allTags.filter { $0.parent == currentParent }
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
            .background(Color.Catppuccin.mantlet)
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
                    // Frequently Used Section (Only show at root level)
                    if currentParent == nil && !frequentlyUsedTags.isEmpty && searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Frequently Used")
                                .font(.subheadline.bold())
                                .foregroundColor(Color.Catppuccin.subtext0)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(frequentlyUsedTags) { tag in
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
                                TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                    toggleSelection(for: tag)
                                } onNavigate: {
                                    withAnimation {
                                        currentParent = tag
                                    }
                                }
                            }
                            
                            if searchText.isEmpty {
                                Button(action: { /* New Tag Action */ }) {
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
                    }
                }
            }
        }
        .padding()
        .background(Color.Catppuccin.base)
    }
    
    private func toggleSelection(for tag: Tag) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
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
                    .padding(.vertical, 8)
                    .padding(.leading, 16)
                    .padding(.trailing, hasChildren ? 8 : 16)
            }
            
            if hasChildren {
                Button(action: onNavigate) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? Color.Catppuccin.base : Color(hex: tag.colorHex))
                        .padding(.trailing, 12)
                        .padding(.vertical, 8)
                }
            }
        }
        .background(
            Capsule()
                .fill(isSelected ? Color(hex: tag.colorHex) : Color.Catppuccin.mantlet)
        )
        .overlay(
            Capsule()
                .stroke(Color(hex: tag.colorHex), lineWidth: 1)
        )
    }
}
