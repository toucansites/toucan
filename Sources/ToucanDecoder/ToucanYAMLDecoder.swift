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
            throw ToucanDecoderError.decoding(error)
        }
    }

    //    init(resolver: Resolver = .default.removing(.timestamp)) {
    //        self.resolver = resolver
    //    }
    //
    //    func parse<T>(_ yaml: String, as: T.Type) throws -> T? {
    //        do {
    //            return try Yams.load(yaml: yaml, resolver) as? T
    //        }
    //        catch {
    //            throw ToucanDecoderError.decoding(error)
    //        }
    //    }
}
