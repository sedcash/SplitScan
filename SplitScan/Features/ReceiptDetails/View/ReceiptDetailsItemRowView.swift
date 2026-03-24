import SwiftUI

struct ReceiptDetailsItemRowView: View {
    
    var item: ReceiptLineItem
    var onTap: () -> Void
    var decrementAction: () -> Void
    var incrementAction: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Button {
                onTap()
            } label: {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(item.name)
                            .font(Font.headline)
                        Spacer()
                        Text(item.totalPrice.formatted())
                            .font(.headline)
                    
                    }
                    
                    Text("\(item.price.formatted()) each")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
    
            HStack(spacing: Spacing.lg) {
                Text("Quantity:")
                
                Button(action: decrementAction) {
                    Image(systemName: item.hasMoreThanOne ? "minus" : "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(item.hasMoreThanOne ? .black : .red)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    item.hasMoreThanOne ? Color.gray : Color.red,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
                
                Text("\(item.quantity)")
                    .fontWeight(.bold)
        
                
                Button(action: incrementAction) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
        }
        .padding()
    }
    
}

#Preview {
    ReceiptDetailsItemRowView(
        item: PreviewData.pizzaItem,
        onTap: {},
        decrementAction: {},
        incrementAction: {}
    )
}
