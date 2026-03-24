import Foundation
import Observation

@MainActor
@Observable
final class ReceiptFlowViewModel {
    enum LeadingAction {
        case none
        case back
    }

    // MARK: - Public State

    var path: [ReceiptRoute] = []

    // MARK: - Derived

    var currentRoute: ReceiptRoute? {
        path.last
    }

    var leadingAction: LeadingAction {
        switch currentRoute {
        case nil, .history, .scan:
            .none

        case .receiptDetails, .assignItems, .savedReceiptDetail, .summary:
            .back
        }
    }

    var shouldShowBottomBar: Bool {
        switch currentRoute {
        case nil, .history:
            true
        default:
            false
        }
    }

    // MARK: - Public Methods

    func handleLeadingAction() {
        switch leadingAction {
        case .none:
            break
        case .back:
            pop()
        }
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popTo(_ target: ReceiptRoute) {
        guard let index = path.lastIndex(of: target) else { return }
        path = Array(path.prefix(index + 1))
    }

    func popToRoot() {
        path.removeAll()
    }

    func push(_ route: ReceiptRoute) {
        path.append(route)
    }

    func replaceTop(with route: ReceiptRoute) {
        guard !path.isEmpty else {
            path = [route]
            return
        }

        path[path.count - 1] = route
    }

    func startNewScanFlow() {
        popToRoot()
        push(.scan)
    }
}
