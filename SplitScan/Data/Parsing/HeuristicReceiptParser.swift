import Foundation

struct HeuristicReceiptParser: ReceiptParsing {
    
    func parse(ocr: OCRResult, currencyCode: String) -> Receipt {
        let cleaned = ocr.lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let merchant = cleaned.first ?? "Receipt"
        let totals = extractTotals(from: cleaned, currencyCode: currencyCode)

        let items = mergeDuplicateItems(
            cleaned.compactMap { parseItemLine($0, currencyCode: currencyCode) },
            currencyCode: currencyCode
        )

        return Receipt(
            currencyCode: currencyCode,
            items: items,
            merchantName: merchant,
            totals: totals
        )
    }

    private func parseItemLine(_ line: String, currencyCode: String) -> ReceiptLineItem? {
        let upper = line.uppercased()

        let blocked = [
            "TOTAL", "SUBTOTAL", "TAX", "TIP", "GRATUITY",
            "SERVICE", "AMOUNT DUE", "TABLE", "SERVER",
            "GUEST", "GUESTS", "THANK YOU", "RESTAURANT",
            "SUGGESTED", "CHECK"
        ]

        guard blocked.allSatisfy({ !upper.contains($0) }) else { return nil }
        guard !line.contains("%") else { return nil }

        guard let amount = extractTrailingMoney(line, currencyCode: currencyCode) else {
            return nil
        }

        let withoutAmount = stripTrailingAmount(line)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let quantity = extractLeadingQuantity(withoutAmount) ?? 1
        let name = stripLeadingQuantity(withoutAmount)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else { return nil }

        let unitMinorUnits = amount.minorUnits / max(quantity, 1)

        return ReceiptLineItem(
            name: name,
            price: Money(minorUnits: unitMinorUnits, currencyCode: currencyCode),
            quantity: quantity
        )
    }

//    private func looksLikeSuggestedTipLine(_ line: String) -> Bool {
//        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
//        let pattern = #"^\d{1,2}%\s*="?#
//        return trimmed.range(of: pattern, options: .regularExpression) != nil
//    }

    private func extractTotals(from lines: [String], currencyCode: String) -> ReceiptTotals {
        var subtotal: Money = .zeroUSD
        var tax: Money?
        var tip: Money?
        var serviceFee: Money?
        var grandTotal: Money = .zeroUSD

        for line in lines {
            let upper = line.uppercased()
            let money = extractTrailingMoney(line, currencyCode: currencyCode)

            if upper.contains("SUBTOTAL") {
                subtotal = money ?? .zeroUSD
            } else if upper.contains("TAX") {
                tax = money
            } else if upper.contains("TIP") || upper.contains("GRATUITY") {
                tip = money
            } else if upper.contains("SERVICE FEE") || upper.contains("SERVICE") {
                serviceFee = money
            } else if isGrandTotalLine(upper) {
                grandTotal = money ?? .zeroUSD
            }
        }

        return ReceiptTotals(
            grandTotal: grandTotal,
            serviceFee: serviceFee,
            subtotal: subtotal,
            tax: tax,
            tip: tip
        )
    }

    private func isGrandTotalLine(_ upper: String) -> Bool {
        if upper.contains("SUBTOTAL") { return false }
        if upper.contains("AMOUNT DUE") { return true }
        return upper.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("TOTAL")
    }

    private func extractTrailingMoney(_ line: String, currencyCode: String) -> Money? {
        let normalized = line.replacingOccurrences(of: ",", with: ".")
        let pattern = #"\$?(\d+)(\.\d{2})\s*$"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)

        guard
            let match = regex.firstMatch(in: normalized, range: range),
            let fullRange = Range(match.range, in: normalized)
        else {
            return nil
        }

        let amountString = String(normalized[fullRange]).replacingOccurrences(of: "$", with: "")
        let parts = amountString.split(separator: ".")

        guard
            parts.count == 2,
            let dollars = Int(parts[0]),
            let cents = Int(parts[1])
        else {
            return nil
        }

        return Money(minorUnits: dollars * 100 + cents, currencyCode: currencyCode)
    }

    private func stripTrailingAmount(_ line: String) -> String {
        line.replacingOccurrences(
            of: #"\s+\$?\d+(\.\d{2})\s*$"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractLeadingQuantity(_ line: String) -> Int? {
        let patterns = [
            #"^\s*(\d+)\s*[xX]\b"#,
            #"^\s*(\d+)\b"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let nsRange = NSRange(line.startIndex..<line.endIndex, in: line)

            if let match = regex.firstMatch(in: line, range: nsRange),
               let range = Range(match.range(at: 1), in: line),
               let quantity = Int(line[range]) {
                return quantity
            }
        }

        return nil
    }

    private func stripLeadingQuantity(_ line: String) -> String {
        let patterns = [
            #"^\s*\d+\s*[xX]\s*"#,
            #"^\s*\d+\s+"#
        ]

        var output = line
        for pattern in patterns {
            output = output.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return output
    }

    private func mergeDuplicateItems(
        _ items: [ReceiptLineItem],
        currencyCode: String
    ) -> [ReceiptLineItem] {
        var grouped: [String: ReceiptLineItem] = [:]
        var order: [String] = []

        for item in items {
            let key = item.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            if var existing = grouped[key] {
                let existingTotal = existing.price.minorUnits * existing.quantity
                let newTotal = item.price.minorUnits * item.quantity
                let mergedQuantity = existing.quantity + item.quantity
                let mergedUnitPrice = (existingTotal + newTotal) / max(mergedQuantity, 1)

                existing.quantity = mergedQuantity
                existing.price = Money(minorUnits: mergedUnitPrice, currencyCode: currencyCode)
                grouped[key] = existing
            } else {
                grouped[key] = item
                order.append(key)
            }
        }

        return order.compactMap { grouped[$0] }
    }
}
