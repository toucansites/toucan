import Foundation

extension Dictionary {

    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs) { (_, new) in new }
    }
}
