import SwiftUI

@MainActor
struct ReceiptFlowFactory {
    let viewModelFactory: ViewModelFactory
    let flowViewModel: ReceiptFlowViewModel

    func makeRootView() -> some View {
        let viewModel = viewModelFactory.makeReceiptHistoryViewModel()

        viewModel.onOutput = { output in
            switch output {
            case .startScan:
                flowViewModel.startNewScanFlow()

            case .openReceipt(let receiptID):
                flowViewModel.push(.savedReceiptDetail(receiptID))
            }
        }

        return ReceiptHistoryView(viewModel: viewModel)
    }

    @ViewBuilder
    func makeDestination(for route: ReceiptRoute) -> some View {
        switch route {
        case .history:
            makeHistoryView()
        case .scan:
            makeScanView()
        case .receiptDetails(let receipt):
            makeReceiptDetailsView(receipt: receipt)
        case .assignItems(let receipt):
            makeAssignItemsView(receipt: receipt)
        case .summary(let receipt, let mode):
            makeSummaryView(receipt: receipt, mode: mode)
        case .savedReceiptDetail(let receiptID):
            makeSavedReceiptDetailView(receiptID: receiptID)
        }
    }

    private func makeHistoryView() -> some View {
        let viewModel = viewModelFactory.makeReceiptHistoryViewModel()

        viewModel.onOutput = { output in
            switch output {
            case .startScan:
                flowViewModel.startNewScanFlow()

            case .openReceipt(let receiptID):
                flowViewModel.push(.savedReceiptDetail(receiptID))
            }
        }

        return ReceiptHistoryView(viewModel: viewModel)
    }

    private func makeSavedReceiptDetailView(receiptID: UUID) -> some View {
        let viewModel = viewModelFactory.makeSavedReceiptViewModel(receiptID: receiptID)

        viewModel.onOutput = { output in
            switch output {
            case .summary(let receipt):
                flowViewModel.push(.summary(receipt: receipt, mode: .saved))

            case .retakePhoto:
                flowViewModel.startNewScanFlow()

            case .back:
                flowViewModel.pop()
            }
        }

        return SavedReceiptDetailsView(viewModel: viewModel)
    }

    private func makeReceiptDetailsView(receipt: Receipt) -> some View {
        let viewModel = viewModelFactory.makeReceiptDetailsViewModel(receipt: receipt)

        viewModel.onOutput = { output in
            switch output {
            case .retakePhoto:
                flowViewModel.pop()

            case .assignments(let updatedReceipt):
                flowViewModel.push(.assignItems(updatedReceipt))

            case .cancel:
                flowViewModel.popToRoot()
            }
        }

        return ReceiptDetailsView(
            viewModel: viewModel,
            presentationStyle: .pushed
        )
    }

    private func makeScanView() -> some View {
        let viewModel = viewModelFactory.makeScanReceiptViewModel()

        viewModel.onOutput = { output in
            switch output {
            case .cancel:
                flowViewModel.popToRoot()

            case .receiptDetails(let receipt):
                flowViewModel.push(.receiptDetails(receipt))
            }
        }

        return ScanReceiptView(viewModel: viewModel)
    }

    private func makeAssignItemsView(receipt: Receipt) -> some View {
        let viewModel = viewModelFactory.makeAssignItemsViewModel(receipt: receipt)

        viewModel.onOutput = { output in
            switch output {
            case .summary(let updatedReceipt):
                flowViewModel.push(.summary(receipt: updatedReceipt, mode: .edit))
            }
        }

        return AssignItemsView(viewModel: viewModel)
    }

    private func makeSummaryView(
        receipt: Receipt,
        mode: SummaryMode
    ) -> some View {
        let viewModel = viewModelFactory.makeSummaryViewModel(
            receipt: receipt,
            mode: mode
        )

        viewModel.onOutput = { output in
            switch output {
            case .editAssignments(let updatedReceipt):
                flowViewModel.replaceTop(with: .assignItems(updatedReceipt))

            case .editItems(let updatedReceipt):
                flowViewModel.replaceTop(with: .receiptDetails(updatedReceipt))

            case .save(let savedID):
                flowViewModel.popToRoot()
                DispatchQueue.main.async {
                    flowViewModel.push(.savedReceiptDetail(savedID))
                }

            case .share:
                break

            case .done:
                switch mode {
                case .edit, .share:
                    flowViewModel.popToRoot()
                case .saved:
                    flowViewModel.pop()
                }
            }
        }

        return SummaryView(viewModel: viewModel)
    }
}
