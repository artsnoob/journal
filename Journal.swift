import SwiftUI
import PhotosUI

// Custom color extension
extension Color {
    static let customBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) : .white
    })
    static let customSecondaryBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) : UIColor.secondarySystemBackground
    })
}

struct ContentView: View {
    @State private var showingNewEntrySheet = false
    @State private var journalEntries: [JournalEntry] = []
    @State private var showingMenu = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTag: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if let selectedTag = selectedTag {
                        HStack {
                            Text("Filtered by: \(selectedTag)")
                            Spacer()
                            Button("Clear") {
                                self.selectedTag = nil
                            }
                        }
                        .padding()
                        .background(Color.customSecondaryBackground)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEntries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry, entries: $journalEntries, onTagSelect: { tag in
                                    self.selectedTag = tag
                                })) {
                                    JournalEntryView(entry: entry, onTagTap: { tag in
                                        self.selectedTag = tag
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationBarItems(trailing: Button(action: {
                showingMenu = true
            }) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.purple)
            })
            .overlay(
                Button(action: {
                    showingNewEntrySheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
                , alignment: .bottomTrailing
            )
        }
        .sheet(isPresented: $showingNewEntrySheet) {
            NewEntryView(isPresented: $showingNewEntrySheet, onSave: { newEntry in
                journalEntries.insert(newEntry, at: 0)
                saveEntries()
            })
        }
        .actionSheet(isPresented: $showingMenu) {
            ActionSheet(title: Text("Menu"), buttons: [
                .default(Text(isDarkMode ? "Light Mode" : "Dark Mode")) {
                    isDarkMode.toggle()
                },
                .cancel()
            ])
        }
        .onAppear(perform: loadEntries)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
    
    var filteredEntries: [JournalEntry] {
        guard let selectedTag = selectedTag else {
            return journalEntries
        }
        return journalEntries.filter { $0.tags.contains(selectedTag) }
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }
    
    func loadEntries() {
        if let savedEntries = UserDefaults.standard.data(forKey: "journalEntries") {
            if let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: savedEntries) {
                journalEntries = decodedEntries
            }
        }
    }
}

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var imageNames: [String]
    var tags: [String]
}

struct JournalEntryView: View {
    let entry: JournalEntry
    let onTagTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if let firstImageName = entry.imageNames.first,
               let uiImage = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent(firstImageName).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            }
            
            VStack(spacing: 8) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                HStack {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        Button(action: {
                            onTagTap(tag)
                        }) {
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(8)
                        }
                    }
                    if entry.tags.count > 3 {
                        Text("+\(entry.tags.count - 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.customSecondaryBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct EntryDetailView: View {
    @State var entry: JournalEntry
    @Binding var entries: [JournalEntry]
    let onTagSelect: (String) -> Void
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !entry.imageNames.isEmpty {
                    TabView {
                        ForEach(entry.imageNames, id: \.self) { imageName in
                            if let uiImage = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent(imageName).path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                    .clipped()
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                
                Text(entry.title)
                    .font(.title)
                
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(entry.content)
                    .font(.body)
                
                HStack {
                    ForEach(entry.tags, id: \.self) { tag in
                        Button(action: {
                            onTagSelect(tag)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.customBackground.edgesIgnoringSafeArea(.all))
        .navigationBarItems(trailing: HStack {
            Button(action: {
                showingEditSheet = true
            }) {
                Text("Edit")
            }
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash")
            }
        })
        .sheet(isPresented: $showingEditSheet) {
            NewEntryView(isPresented: $showingEditSheet, entry: entry, onSave: { updatedEntry in
                if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                    entries[index] = updatedEntry
                    entry = updatedEntry
                    saveEntries()
                }
            })
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Entry"),
                message: Text("Are you sure you want to delete this entry?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteEntry()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func deleteEntry() {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            saveEntries()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }
}

struct NewEntryView: View {
    @Binding var isPresented: Bool
    var entry: JournalEntry?
    let onSave: (JournalEntry) -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var tags: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var existingImageNames: [String] = []
    @State private var showingImagePicker = false
    @State private var imagesToDelete: Set<String> = []
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
                TextField("Tags (comma-separated)", text: $tags)
                
                Section(header: Text("Photos")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Add Photos")
                    }
                    
                    ForEach(Array(zip(existingImageNames + Array(repeating: "", count: max(0, selectedImages.count - existingImageNames.count)), selectedImages.indices)), id: \.1) { imageName, index in
                        HStack {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                            
                            Spacer()
                            
                            Button(action: {
                                if !imageName.isEmpty {
                                    imagesToDelete.insert(imageName)
                                }
                                selectedImages.remove(at: index)
                                if index < existingImageNames.count {
                                    existingImageNames.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") {
                    let newImageNames = saveNewImages()
                    let updatedImageNames = existingImageNames + newImageNames
                    let newEntry = JournalEntry(
                        id: entry?.id ?? UUID(),
                        title: title,
                        content: content,
                        date: entry?.date ?? Date(),
                        imageNames: updatedImageNames,
                        tags: tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                    )
                    onSave(newEntry)
                    deleteImages(imagesToDelete)
                    isPresented = false
                }
            )
        }
        .background(Color.customBackground.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(images: $selectedImages)
        }
        .onAppear {
            if let entry = entry {
                title = entry.title
                content = entry.content
                tags = entry.tags.joined(separator: ", ")
                existingImageNames = entry.imageNames
                selectedImages = entry.imageNames.compactMap { imageName in
                    UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent(imageName).path)
                }
            }
        }
    }
    
    func saveNewImages() -> [String] {
        let newImagesCount = selectedImages.count - existingImageNames.count
        guard newImagesCount > 0 else { return [] }
        
        return selectedImages.suffix(newImagesCount).compactMap { image in
            let imageName = UUID().uuidString
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = getDocumentsDirectory().appendingPathComponent(imageName)
                try? data.write(to: filename)
                return imageName
            }
            return nil
        }
    }
    
    func deleteImages(_ imageNames: Set<String>) {
        for imageName in imageNames {
            let filepath = getDocumentsDirectory().appendingPathComponent(imageName)
            try? FileManager.default.removeItem(at: filepath)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // 0 means no limit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}
