import Foundation

enum EditSheetMode: Identifiable, Equatable {
    
    case addItem
    case editItem(itemID: UUID)
    case editReceiptInfo
    case addParticipant
    
    var id: String {
        switch self {
        case .editReceiptInfo:
            "editReceiptInfo"
        case .editItem(let itemID):
            "editItem_\(itemID.uuidString)"
        case .addItem:
            "addItem"
        case .addParticipant:
            "addParticipant"
        }
    }

    var title: String {
        switch self {
        case .editReceiptInfo:
            "Edit Receipt Info"
        case .editItem:
            "Edit Item"
        case .addItem:
            "Add New Item"
        case .addParticipant:
            "Add Person"
        }
    }

    var saveButtonTitle: String {
        switch self {
        case .addItem, .addParticipant:
            "Add"
        case .editReceiptInfo, .editItem:
            "Save Changes"
        }
        
        
    }
    
}
