import Testing
@testable import ToucanSDK

@Suite
struct StringExtensionTestSuite {

    @Test
    func validDatePrefix() {
        let validString = "2023-06-13-example"
        #expect(validString.hasDatePrefix())
    }

    @Test
    func invalidDatePrefixWrongFormat() {
        let invalidString = "13-06-2023-example"
        #expect(invalidString.hasDatePrefix() == false)
    }

    @Test
    func invalidDatePrefixNonNumeric() {
        let invalidString = "2023-06-aa-example"
        #expect(invalidString.hasDatePrefix() == false)
    }

    @Test
    func invalidDatePrefixShortString() {
        let shortString = "2023-06-1"
        #expect(shortString.hasDatePrefix() == false)
    }

    @Test
    func emptyString() {
        let emptyString = ""
        #expect(emptyString.hasDatePrefix() == false)
    }

    @Test
    func noHyphenSuffix() {
        let noHyphenString = "2023-06-13example"
        #expect(noHyphenString.hasDatePrefix() == false)
    }

    @Test
    func validDatePrefixWithDifferentContent() {
        let validString = "2023-06-13-12345"
        #expect(validString.hasDatePrefix())
    }

    @Test
    func validDatePrefixAtStartOfString() {
        let validString = "2023-06-13-"
        #expect(validString.hasDatePrefix())
    }
}
