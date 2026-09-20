import XCTest

/// Proves the UI bundle can launch the app under test on the simulator.
///
/// If `TEST_TARGET_NAME` were wrong, or the app crashed on launch, this would fail rather
/// than silently pass.
final class LaunchUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testAppLaunchesAndRendersRootContent() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertEqual(app.state, .runningForeground)
    XCTAssertTrue(
      app.staticTexts["Hello, world!"].waitForExistence(timeout: 10),
      "The root view did not render. Update this assertion when ContentView is replaced in #3."
    )
  }
}
