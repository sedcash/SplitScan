import SwiftUI

struct ReceiptHistoryView: View {
    enum Metrics {
        static let contentPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 20
        static let filterSpacing: CGFloat = 8
    }

    @State var viewModel: ReceiptHistoryViewModel

    init(viewModel: ReceiptHistoryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScreenShellView {
            header
        } content: {
            content
        } footer: {
            footer
        }
        .onAppear {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            Text("Receipts")
                .font(.largeTitle.weight(.semibold))

            TextFieldWithImage(
                imageName: "magnifyingglass",
                placeholder: "Search receipts...",
                text: $viewModel.searchText
            )

            filterButtons
        }
        .padding(Metrics.contentPadding)
    }

    private var content: some View {
        Group {
            if viewModel.filteredRows.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(viewModel.filteredRows) { row in
                            ReceiptListRowView(row: row)
                                .onTapGesture {
                                    viewModel.receiptTapped(row.id)
                                }
                        }
                    }
                    .padding(Metrics.contentPadding)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var filterButtons: some View {
        HStack(spacing: Metrics.filterSpacing) {
            ForEach(ReceiptFilter.allCases, id: \.self) { filter in
                PrimaryButton(
                    title: filter.rawValue.capitalized,
                    style: viewModel.selectedFilter == filter ? .primary : .secondary,
                    width: .fit
                ) {
                    viewModel.selectedFilter = filter
                }
            }
        }
    }

    private var footer: some View {
        FooterButtonView(
            title: "Scan New Receipt",
            leadingSystemImage: "document.viewfinder",
            isEnabled: true,
            action: viewModel.scanNewReceiptPressed
        )
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Text("No receipts found")
                .font(.headline)

            Text("Try adjusting your search or scan a new receipt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(Metrics.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Receipts History") {
    ReceiptHistoryView(
        viewModel: PreviewFactory.makeReceiptHistoryViewModel()
    )
}
