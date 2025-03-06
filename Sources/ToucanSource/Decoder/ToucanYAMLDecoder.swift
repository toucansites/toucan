import Foundation
import Yams

public struct ToucanYAMLDecoder: ToucanDecoder {

    public init() {

    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanDecoderError) -> T {
        do {
            let decoder = YAMLDecoder()
            return try decoder.decode(type, from: data)
        }
        catch {
            throw .decoding(error)
        }
    }

}
