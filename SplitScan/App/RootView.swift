import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
   

    var body: some View {
        let environment = AppEnvironment(modelContext: modelContext)
        let factory = environment.viewModelFactory
        ReceiptFlowView(viewModelFactory: factory)
    }
}
