import SwiftUI
import SwiftData

@main
struct SplitScanApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReceiptEntity.self,
            ReceiptItemEntity.self,
            ParticipantEntity.self,
            ItemAssignmentEntity.self,
            PaymentRecordEntity.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
