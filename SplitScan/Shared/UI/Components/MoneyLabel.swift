import SwiftUI

struct MoneyLabel: View {

    let title: String
    var titleFont: Font = .title3
    var titleColor: Color = .primary
    let value: String
    var valueFont: Font = .title3
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)
            
            Spacer()
            
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
        }
    }
    
}
