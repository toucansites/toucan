import Testing
@testable import ToucanSDK

@Suite
struct DateFormatterTestSuite {

    @Test
    func iso8601() throws {

        let dateString = "2023-11-20T02:11:29.158Z"
        let formatter = DateFormatters.iso8601

        let date = try #require(formatter.date(from: dateString))

        let expectation = 1700446289.158
        #expect(date.timeIntervalSince1970 == expectation)

        let formattedString = formatter.string(from: date)
        #expect(formattedString == dateString)
    }
}
