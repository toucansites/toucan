import Testing
@testable import ToucanSDK

@Suite
struct MinifyHTMLTestSuite {

    @Test
    func minify() throws {

        let html =
            "<html>   <body>   <h1>Hello, world!</h1>   </body>   </html>"
        let minifiedHTML = html.minifyHTML()
        #expect(minifiedHTML.isEmpty == false)
    }

}
