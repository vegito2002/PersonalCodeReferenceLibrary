define([
    'src/models/ChessboardModel',
    'ServerMock',

    'test/fixtures/ChessApi'
], function(
    Chessboard,
    serverMock,

    fixtures
    ) {
    describe("The Chessboard", function() {
        var board;

        describe("when in the initial state", function() {

            beforeEach(function(done) {
                board = new Chessboard();

                serverMock.add({
                    url: board.url(),
                    response: fixtures.initialBoardState
                });

                serverMock.fetchAndWait(board, done);
            });

            afterEach(function() {
                // TODO:  reset the mocked server to have no mocked URLs
//                serverMock.reset();
            });

            it("should be an object", function() {
                expect(board).toBeDefined();
            });

            it("starts with white as the first player", function() {
                expect(board.get('currentPlayer')).toEqual('White');
            });
        });

        describe("when Black is in check", function(done) {
            beforeEach(function() {
                serverMock.add({
                    url: board.url(),
                    response: fixtures.boardInCheckState
                });

                serverMock.fetchAndWait(board, done);
            });

            it("can tell if the board when the board is in check", function() {
                expect(board.isInCheck()).toEqual(true);
            });

        });


    });
});