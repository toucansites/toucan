import Foundation

extension String {

    func slice(
        from: String,
        to: String
    ) -> String? {
        guard
            let fromIndex = range(of: from)?.upperBound,
            let toIndex = self[fromIndex...].range(of: to)?.lowerBound
        else {
            return nil
        }
        return String(self[fromIndex..<toIndex])
    }
}
