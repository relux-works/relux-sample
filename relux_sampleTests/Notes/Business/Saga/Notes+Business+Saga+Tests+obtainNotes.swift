import Testing
import SwiftMocks
@testable import relux_sample

extension Notes_Business_Saga_Tests {
    fileprivate enum SuccessPhantom {}
    @Test func obtainNotes_Success() async throws {
        // Arrange
        let reluxLogger = await Relux.Testing.MockModule<Action, Effect, SuccessPhantom>()
        _ = await Task { @MainActor in await SampleApp.relux.register(reluxLogger) }.value

        let service = Notes.Business.ServiceMock()
        let saga = Notes.Business.Saga(svc: service)

        service.mock.getNotesCalls.mockCall {
            .success([])
        }


        // Act
//        await saga.apply(Effect.prepareOrderESimRequest)
//
//        // Assert
//        #expect(tokenProvider.mock.getAccessTokenCalls.callsCount == 1)
//
//        let successAction = await reluxLogger.waitAction(Action.orderESimRequestPrepared(request: urlRequest))
//        #expect(successAction.isNotNil)
    }
}
