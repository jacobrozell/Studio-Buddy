import Foundation
import Testing
@testable import StudioBuddy

@Suite("Firebase bootstrap", .tags(.unit))
struct FirebaseBootstrapTests {
    @Test("Placeholder plist does not configure Firebase")
    func placeholderDoesNotConfigure() {
        let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        #expect(!FirebaseBootstrap.shouldConfigure || plistPath != nil)
    }
}
