import Foundation

public struct ToucanJSONDecoder: ToucanDecoder {

    public init() {

    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanDecoderError) -> T {
        do {
            let decoder = JSONDecoder()
            decoder.allowsJSON5 = true
            return try decoder.decode(type, from: data)
        }
        catch {
            throw ToucanDecoderError.decoding(error)
        }
    }

}
