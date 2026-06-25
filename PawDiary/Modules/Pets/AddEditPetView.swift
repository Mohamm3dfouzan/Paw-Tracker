import SwiftUI
import SwiftData
import PhotosUI

struct AddEditPetView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    var pet: Pet?

    @State private var name = ""
    @State private var species: PetSpecies = .dog
    @State private var breed = ""
    @State private var dob: Date = .now
    @State private var hasDOB = true
    @State private var sex: PetSex = .unknown
    @State private var microchipID = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        if let avatarData, let ui = UIImage(data: avatarData) {
                            Image(uiImage: ui).resizable().scaledToFill()
                                .frame(width: 72, height: 72).clipShape(Circle())
                        } else {
                            Circle().fill(AppTheme.warmGradient).frame(width: 72, height: 72)
                                .overlay(Image(systemName: species.symbol).foregroundStyle(.white))
                        }
                        PhotosPicker("Choose Photo", selection: $avatarItem, matching: .images)
                    }
                }
                Section("Identity") {
                    TextField("Name", text: $name)
                    Picker("Species", selection: $species) {
                        ForEach(PetSpecies.allCases) { Text($0.label).tag($0) }
                    }
                    TextField("Breed (optional)", text: $breed)
                    Picker("Sex", selection: $sex) {
                        ForEach(PetSex.allCases) { Text($0.label).tag($0) }
                    }
                }
                Section("Date of Birth") {
                    Toggle("Known", isOn: $hasDOB)
                    if hasDOB {
                        DatePicker("Born", selection: $dob, in: ...Date.now, displayedComponents: .date)
                    }
                }
                Section("Microchip") {
                    TextField("Microchip ID (optional)", text: $microchipID)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle(pet == nil ? "Add Pet" : "Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .task(id: avatarItem) {
                if let avatarItem, let data = try? await avatarItem.loadTransferable(type: Data.self) {
                    avatarData = data
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let pet else { return }
        name = pet.name
        species = pet.species
        breed = pet.breed
        if let d = pet.dob { dob = d; hasDOB = true } else { hasDOB = false }
        sex = pet.sex
        microchipID = pet.microchipID
        avatarData = pet.avatarData
    }

    private func save() {
        if let pet {
            pet.name = name
            pet.species = species
            pet.breed = breed
            pet.dob = hasDOB ? dob : nil
            pet.sex = sex
            pet.microchipID = microchipID
            pet.avatarData = avatarData
        } else {
            let new = Pet(name: name, species: species, breed: breed, dob: hasDOB ? dob : nil, sex: sex, microchipID: microchipID, avatarData: avatarData)
            ctx.insert(new)
        }
        try? ctx.save()
        dismiss()
    }
}
