import Foundation

public struct CocoaVersion: CustomStringConvertible, Comparable, Equatable {
    
    public var major: Int
    public var minor: Int
    public var patch: Int
    
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public init(string: String) {
        let comps = string.components(separatedBy: ".")
        guard comps.count == 3,
              let maj = Int(comps[0]),
              let min = Int(comps[1]),
              let pat = Int(comps[2]) else {
            fatalErrorInDebug("Invalid cocoa version string \(string)")
            self.init(major: 0, minor: 1, patch: 0)
            return
        }

        self.init(major: maj, minor: min, patch: pat)
    }
    
    public enum BumpType: String {
        case patch, minor, major
    }
    
    public mutating func bumpUp(type: BumpType) {
        switch type {
        case .patch:
            patch += 1
            
        case .minor:
            patch = 0
            minor += 1
            
        case .major:
            patch = 0
            minor = 0
            major += 1
        }
    }
    
    public static func < (lhs: CocoaVersion, rhs: CocoaVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
    
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
    
    public static var current: CocoaVersion {
        .init(string: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "NoVersion")
    }
    
}
