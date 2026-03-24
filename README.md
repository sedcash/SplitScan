# DEMO
https://drive.google.com/file/d/1x0jcUui6NOF76Co_l919iBzmCx2jTbQp/view?usp=drive_link

# SplitScan
SplitScan is a SwiftUI iOS app that simplifies splitting restaurant bills for groups. It uses OCR to scan receipts, extracts line items, assigns costs to participants, calculates individual totals, and generates shareable PDF payment summaries for easy reimbursement.

---

## Features

- Scan receipts using the camera or upload from gallery
- OCR-based parsing of receipt text
- Automatic item and total extraction
- Assign items to participants with flexible splits
- Calculate totals including tax, tip, and service fees
- Track payments per participant
- Generate a shareable PDF summary of the full breakdown
- View saved receipts and revisit past splits

---

## Demo Flow

1. Scan or upload a receipt
2. Review and adjust parsed items
3. Assign items to participants
4. View summary breakdown
5. Track payments or mark balances as paid
6. Save the receipt
7. Share a PDF summary with the group

---

## Architecture

The app is built using a modular, layered architecture:

- **SwiftUI + Observation** for UI and state management
- **MVVM** pattern for feature separation
- **Repository layer** for data access
- **SwiftData** for local persistence
- **Services layer** for OCR, camera, and parsing

### Key Layers

- `Domain`
  - Core models (Receipt, Participant, ItemAssignment, Money)

- `Data`
  - SwiftData entities
  - Repository + Local Store
  - Image storage

- `Features`
  - Scan
  - Receipt Details
  - Assign Items
  - Summary
  - History

- `Services`
  - Camera service
  - OCR service
  - Receipt parser

---

## Key Technical Decisions

### 1. Separation of Models
Clear separation between:
- Domain models
- Persistence models
- UI-derived models

This prevents state inconsistencies and keeps logic predictable.

---

### 2. Flow-Based Navigation
Custom navigation system using a `NavigationStack` and a centralized `ReceiptFlowViewModel`.

This allows:
- Controlled screen transitions
- Clean back navigation
- Replace/push/pop behavior

---

### 3. Deterministic State Updates
All calculations (totals, splits, payments) are derived from a single source of truth (`Receipt`).

No UI-driven state mutations.

---

### 4. Shareable Summary Export
The app generates a clean, shareable PDF using a dedicated export view.

- Built from SwiftUI
- Rendered using `ImageRenderer`
- Converted to PDF
- Shared via system share sheet

---

## Tech Stack

- Swift
- SwiftUI (iOS 17+)
- SwiftData
- Vision (OCR)
- AVFoundation (Camera)
- UIKit (PDF rendering + sharing)

---

## Future Improvements

- Multi-page PDF export for large receipts
- Improved OCR accuracy and parsing heuristics
- Cloud sync / backup
- Split by percentage or custom weights
- Better error handling and loading states
- UI polish and animations

---

## Notes

This project was built as part of interview preparation and focuses on:

- Clean architecture
- State management
- Real-world feature complexity
- End-to-end product thinking
