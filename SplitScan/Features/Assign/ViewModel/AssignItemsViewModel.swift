import Foundation
import Observation

@MainActor
@Observable
final class AssignItemsViewModel {
    enum Output {
        case summary(Receipt)
    }

    // MARK: - Public State

    var addParticipantErrors: [ValidationError] = []
    var addParticipantState: EditFormState = .addParticipant(
        name: "",
        color: "#2563EB"
    )
    var editSheetMode: EditSheetMode?
    var onOutput: ((Output) -> Void)?
    var receipt: Receipt

    // MARK: - Derived

    var allItemsAssigned: Bool {
        receipt.items.allSatisfy { item in
            receipt.itemAssignments.contains { $0.itemID == item.id }
        }
    }
    
    var canSaveParticipant: Bool {
        addParticipantValidationErrors(for: addParticipantState).isEmpty
    }

    var participants: [Participant] {
        receipt.participants
    }

    // MARK: - Init

    init(receipt: Receipt) {
        self.receipt = receipt
    }

    // MARK: - Public Methods

    func assignedParticipants(for itemID: UUID) -> [Participant] {
        let assignedIDs = receipt.itemAssignments
            .filter { $0.itemID == itemID }
            .compactMap(\.participantID)

        return receipt.participants.filter { assignedIDs.contains($0.id) }
    }

    func availableParticipantColors() -> [String] {
        let usedColors = Set(participants.map(\.colorHex))
        let unusedColors = Participant.participantPalette.filter { !usedColors.contains($0) }
        return unusedColors.isEmpty ? Participant.participantPalette : unusedColors
    }

    func dismissSheet() {
        addParticipantErrors = []
        editSheetMode = nil
    }

    func removeParticipant(id: UUID) {
        receipt.itemAssignments.removeAll { $0.participantID == id }
        receipt.participants.removeAll { $0.id == id }

        for item in receipt.items {
            normalizeAssignments(for: item.id)
        }
    }

    func saveAddParticipant() {
        let errors = addParticipantValidationErrors(for: addParticipantState)
        addParticipantErrors = errors

        guard errors.isEmpty else { return }

        addParticipant(
            name: addParticipantState.name,
            colorHex: addParticipantState.color
        )

        addParticipantState = .addParticipant(
            name: "",
            color: availableParticipantColors().first ?? "#2563EB"
        )
        addParticipantErrors = []
        editSheetMode = nil
    }

    func setEqualAssignment(for itemID: UUID) {
        let participantIDs = receipt.participants.map(\.id)

        receipt.itemAssignments.removeAll { $0.itemID == itemID }

        guard !participantIDs.isEmpty else { return }

        let denominator = participantIDs.count

        for participantID in participantIDs {
            receipt.itemAssignments.append(
                ItemAssignment(
                    denominator: denominator,
                    itemID: itemID,
                    numerator: 1,
                    participantID: participantID
                )
            )
        }
    }

    func showAddParticipantSheet() {
        addParticipantErrors = []
        addParticipantState = .addParticipant(
            name: "",
            color: availableParticipantColors().first ?? "#2563EB"
        )
        editSheetMode = .addParticipant
    }

    func toggleAssignment(itemID: UUID, participantID: UUID) {
        if let index = receipt.itemAssignments.firstIndex(where: {
            $0.itemID == itemID && $0.participantID == participantID
        }) {
            receipt.itemAssignments.remove(at: index)
        } else {
            receipt.itemAssignments.append(
                ItemAssignment(
                    itemID: itemID,
                    participantID: participantID
                )
            )
        }

        normalizeAssignments(for: itemID)
    }

    func viewSummary() {
        onOutput?(.summary(receipt))
    }

    // MARK: - Private Methods

    private func addParticipant(name: String, colorHex: String = "#2563EB") {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        receipt.participants.append(
            Participant(
                colorHex: colorHex,
                name: trimmedName
            )
        )
    }

    private func addParticipantValidationErrors(for state: EditFormState) -> [ValidationError] {
        var errors = EditFormValidator.validate(mode: .addParticipant, state: state)

        let trimmedName = state.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedName.isEmpty {
            let alreadyExists = participants.contains {
                $0.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
            }

            if alreadyExists {
                errors.append(
                    ValidationError(
                        field: .name,
                        message: "This person is already added."
                    )
                )
            }
        }

        return errors
    }

    private func normalizeAssignments(for itemID: UUID) {
        let indices = receipt.itemAssignments.indices.filter {
            receipt.itemAssignments[$0].itemID == itemID
        }

        guard !indices.isEmpty else { return }

        let denominator = indices.count

        for index in indices {
            receipt.itemAssignments[index].denominator = denominator
            receipt.itemAssignments[index].numerator = 1
        }
    }
}
