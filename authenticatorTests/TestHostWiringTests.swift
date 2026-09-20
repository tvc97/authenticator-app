import Foundation
import Testing

/// Proves the unit bundle is actually injected into the `authenticator` host app.
///
/// If `TEST_HOST` or `BUNDLE_LOADER` were wrong, the bundle would load standalone under the
/// `xctest` runner and these expectations would fail. A placeholder test that cannot fail
/// would let the `unit` tier report PASS for a broken bundle, which is the specific failure
/// this target exists to prevent.
@Suite("Test host wiring")
struct TestHostWiringTests {

  @Test("unit bundle runs inside the host application, not the xctest runner")
  func runsInsideHostApplication() {
    #expect(Bundle.main.bundleURL.pathExtension == "app")
  }

  @Test("the host application is authenticator")
  func hostIsAuthenticator() {
    let executable = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    #expect(executable == "authenticator")
  }
}
