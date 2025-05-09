@testable import PanelPop
import Testing

@Test func canRequestRemotePanel() async throws {
    let panelPop = PanelPop.Initialize("___")

    let welcomePanel = await panelPop.ShowPopup("welcome")

    #expect(welcomePanel != nil)
    #expect(welcomePanel?.name == "Welcome")
}
