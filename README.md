# SwiftUI Journal App

A beautiful and feature-rich journaling app built with SwiftUI for iOS. This app allows users to create, edit, and organize journal entries with support for multiple images, tags, and dark mode.

## Features

- Create and edit journal entries with titles, content, and dates
- Add multiple images to each entry
- Tag entries for easy organization and filtering
- Dark mode support
- Sleek and intuitive user interface
- Custom color schemes that adapt to light and dark modes
- Local data persistence using UserDefaults

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Installation

1. Clone this repository
2. Open the project in Xcode
3. Build and run the app on your iOS device or simulator

## Usage

1. **Creating a new entry**: Tap the "+" button to add a new journal entry. Fill in the title, content, and add tags (comma-separated). You can also add multiple photos to your entry.

2. **Viewing entries**: The main screen displays all your journal entries in a scrollable list. Each entry shows a preview of the content, the first image (if any), and tags.

3. **Editing an entry**: Tap on an entry to view its details. From there, you can edit the entry by tapping the "Edit" button.

4. **Deleting an entry**: In the entry detail view, tap the trash icon to delete the entry. A confirmation dialog will appear before deletion.

5. **Filtering by tags**: Tap on a tag to filter entries by that tag. The filtered view will show at the top of the screen, and you can clear the filter by tapping "Clear".

6. **Switching between light and dark mode**: Tap the menu icon (three horizontal lines) in the top right corner and select "Light Mode" or "Dark Mode" to switch between themes.

## Architecture

This app is built using SwiftUI and follows the MVVM (Model-View-ViewModel) architecture pattern. Key components include:

- `ContentView`: The main view of the app, displaying the list of journal entries and handling navigation.
- `JournalEntry`: The model representing a single journal entry.
- `JournalEntryView`: A reusable view for displaying a journal entry in the list.
- `EntryDetailView`: The view for displaying and editing a single entry.
- `NewEntryView`: A view for creating new entries or editing existing ones.
- `ImagePicker`: A custom view that wraps `PHPickerViewController` for selecting multiple images.

## Data Persistence

The app uses `UserDefaults` to store journal entries locally on the device. Images are saved to the app's documents directory, and their file names are stored as part of the journal entry data.

## Customization

The app uses custom colors that adapt to light and dark modes. You can easily modify these colors in the `Color` extension at the beginning of the `ContentView` file.
