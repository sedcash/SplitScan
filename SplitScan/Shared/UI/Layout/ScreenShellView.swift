import SwiftUI

struct ScreenShellView<Header: View, Content: View, Footer: View>: View {
    let content: Content
       let contentBackground: Color
       let footer: Footer
       let footerBackground: Color
       let header: Header
       let headerBackground: Color

    init(
        headerBackground: Color = Color(.systemBackground),
        contentBackground: Color = Color(.systemGray6),
        footerBackground: Color = Color(.systemBackground),
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.headerBackground = headerBackground
        self.contentBackground = contentBackground
        self.footerBackground = footerBackground
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Divider()

            scrollSection

            Divider()

            footerSection
        }
    }

    private var headerSection: some View {
        header
            .padding(.top, 16)
            .background {
                Rectangle()
                    .fill(headerBackground)
                    .ignoresSafeArea(edges: .top)
            }
    }

    private var scrollSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                content
                    .padding(.bottom, 24)
            }
        }
        .scrollContentBackground(.hidden)
        .background(contentBackground)
    }

    private var footerSection: some View {
        footer
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(footerBackground)
    }
}
