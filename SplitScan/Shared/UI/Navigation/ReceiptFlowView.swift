import SwiftUI

struct ReceiptFlowView: View {
    let viewModelFactory: ViewModelFactory

    @State private var flowViewModel = ReceiptFlowViewModel()

    private var factory: ReceiptFlowFactory {
        ReceiptFlowFactory(
            viewModelFactory: viewModelFactory,
            flowViewModel: flowViewModel
        )
    }

    var body: some View {
        NavigationStack(path: $flowViewModel.path) {
            factory.makeRootView()
                .navigationDestination(for: ReceiptRoute.self) { route in
                    factory.makeDestination(for: route)
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    leadingToolbar
                }
        }
    }

    @ToolbarContentBuilder
    private var leadingToolbar: some ToolbarContent {
        if flowViewModel.leadingAction == .back {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    flowViewModel.handleLeadingAction()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.headline)
                }
            }
        }
    }
}
