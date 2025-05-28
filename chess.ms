d"""
Module for chess game analysis.
"""

enum Pieces {
    w_pawn,
    w_rook,
    w_knight,
    w_bishop,
    w_queen,
    w_king,
    b_pawn,
    b_rook,
    b_knight,
    b_bishop,
    b_queen,
    b_king
}

fun piece2str(p:Pieces, p_for_pawn:Bool=true) {
    switch(p) {
        case Pieces.w_pawn, Pieces.b_pawn: {
            if (p_for_pawn)
                return "p"
            return ""
        }
        case Pieces.w_rook, Pieces.b_rook: return "R"
        case Pieces.w_knight, Pieces.b_knight: return "N"
        case Pieces.w_bishop, Pieces.b_bishop: return "B"
        case Pieces.w_queen, Pieces.b_queen: return "Q"
        case Pieces.w_king, Pieces.b_king: return "K"
        default: {
            assert(false, "missing case")
            return "?"
        }
    }
}

class Move {
    fun Move(from:List, to:List, piece:Pieces, notation:String) {
        assert(from.length() == 2, "move starting position has to be 2d array of ints")
        assert(to.length() == 2, "move ending position has to be 2d array of ints")
        this.from = from
        this.to = to
        this.piece = piece
        this.notation = notation
    }

    fun __String() {
        return piece2str(this.piece) ++ [this.from, this.to]
    }
}

class Game {

    enum Result {
        NOT_FINISHED
        DRAW
        WHITE_WIN
        BLACK_WIN
    }

    fun Game(moves:List, result:Result=Result.NOT_FINISHED) {
        this.moves = moves
        this.result = result
    }

    fun __String() {
        mnum = 1
        i = 0
        txt = ""
        while (i < this.moves.length()) {
            txt ++= mnum ++ ". " ++ this.moves[i]
            i += 1
            if (i < this.moves.length()) {
                txt ++= ", " ++ this.moves[i]
                i += 1
            }
            txt ++= "\n"
            mnum += 1
        }
        txt ++= f"Result: {this.result}\n"
        return txt
    }
}

class Board {
    
    fun Board(game:Game) {
        this.game = game
        this.index = 0
        this.board = [
            [Pieces.w_rook, Pieces.w_knight, Pieces.w_bishop, Pieces.w_queen, Pieces.w_king, Pieces.w_bishop, Pieces.w_knight, Pieces.w_rook],
            [Pieces.w_pawn, Pieces.w_pawn,   Pieces.w_pawn,   Pieces.w_pawn,  Pieces.w_pawn, Pieces.w_pawn,   Pieces.w_pawn,   Pieces.w_pawn],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [Pieces.b_pawn, Pieces.b_pawn,   Pieces.b_pawn,   Pieces.b_pawn,  Pieces.b_pawn, Pieces.b_pawn,   Pieces.b_pawn,   Pieces.b_pawn],
            [Pieces.b_rook, Pieces.b_knight, Pieces.b_bishop, Pieces.b_queen, Pieces.b_king, Pieces.b_bishop, Pieces.b_knight, Pieces.b_rook],
        ]
    }

    fun apply_move(move:Move) {
        this.board[move.to[0]][move.to[1]] = this.board[move.from[0]][move.from[1]]
        this.board[move.from[0]][move.from[1]] = nil
    }

    fun move(num:Int=1) {
        moves = this.game.moves
        while (num > 0 && this.index < moves.length()) {
            ~this.apply_move(moves[this.index])
            this.index += 1
            num -= 1
        }
    }

    fun __String() {
        txt = ""
        for (row: this.board[-1..-this.board.length()-1]) {
            for (p: row) {
                if (p == nil)
                    txt ++= "  "
                else
                    txt ++= piece2str(p, true) ++ " "
            }
            txt ++= "\n"
        }
        return txt
    }
}

space pgn {

enum TokenType {
    MOVE_NUMBER,
    COLUMN,
    ROW,
    PIECE,
    CHECK,
    MATE,
    RESULT,
    TAKES,
    PROMOTION,
    SHORT_CASTLE,
    LONG_CASTLE,
    WS,
    END
}

class PGNScanner {
    
    class PGNToken {
        fun PGNToken(type:TokenType, value:String) {
            this.type = type
            this.value = value
        }

        fun __String() {
            return "(" ++ this.type ++ ")" ++ this.value
        }
    }

    fun PGNScanner(txt:String) {
        this.txt = txt
        this.tokens = []
        this.curr_token = 0
        ~tokenize(txt)
    }

    fun tokenize(txt:String) {
        i = 0
        while (i < txt.length()) {
            c = txt[i]
            token = nil
            if (ord(c) >= 48 and ord(c) <= 57) { // "0" - "9"
                if (i+4 < txt.length() && txt[i..i+5] == "0-0-0") {
                    token = PGNToken(TokenType.LONG_CASTLE, "0-0-0")
                    i += 4
                } else if (i+2 < txt.length() && txt[i..i+3] == "0-0") {
                    token = PGNToken(TokenType.SHORT_CASTLE, "0-0")
                    i += 2
                } else if (i+1 < txt.length() && (txt[i+1] == "." || (ord(txt[i+1]) >= 48 && ord(txt[i+1]) <= 57))) {
                    num = c
                    i += 1
                    while (ord(txt[i]) >= 48 and ord(txt[i]) <= 57) {
                        num ++= txt[i]
                        i += 1
                    }
                    assert(txt[i] == ".", "Expected '.' after move number")
                    token = PGNToken(TokenType.MOVE_NUMBER, num++".")
                } else if (i+1 < txt.length() && txt[i+1] == "-") { // 1-0, 0-1
                    assert(i + 2 < txt.length(), "Incorrect result")
                    res = txt[i..i+3]
                    assert(res == "1-0" or res == "0-1", "Incorrect result value")
                    token = PGNToken(TokenType.RESULT, res)
                    i += 2
                } else if (i+1 < txt.length() && txt[i+1] == "/") { // 1/2-1/2
                    assert(i + 6 < txt.length(), "Incorrect draw result")
                    res = txt[i..i+7]
                    assert(res == "1/2-1/2", "Incorrect draw result value")
                    token = PGNToken(TokenType.RESULT, res)
                    i += 6
                } else {
                    assert(c != "9" and c != "0", "Rows are 1 to 9, but found: "++c)
                    token = PGNToken(TokenType.ROW, c)
                }
            } else if (ord(c) >= 97 and ord(c) <= 104) { // a-h
                token = PGNToken(TokenType.COLUMN, c)
            } else if (i+4 < txt.length() && txt[i..i+5] == "O-O-O") {
                token = PGNToken(TokenType.LONG_CASTLE, "O-O-O")
                i += 4
            } else if (i+2 < txt.length() && txt[i..i+3] == "O-O") {
                token = PGNToken(TokenType.SHORT_CASTLE, "O-O")
                i += 2
            } else {
                type = nil
                switch(c) {
                    case " ", "\t", "\n": type = TokenType.WS
                    case "K", "Q", "R", "B", "N": type = TokenType.PIECE
                    case "+": type = TokenType.CHECK
                    case "#": type = TokenType.MATE
                    case "x": type = TokenType.TAKES
                    case "*": type = TokenType.RESULT
                    default: assert(false, "Unknown symbol: " ++ c)
                }
                token = PGNToken(type, c)
            }
            ~this.tokens.append(token)
            i += 1
        }
    }

    fun advance() {
        if (this.curr_token >= this.tokens.length()) {
            return PGNToken(TokenType.END, "")
        }
        t = this.tokens[this.curr_token]
        this.curr_token += 1
        return t
    }

    fun check(type:TokenType) {
        if (this.curr_token >= this.tokens.length()) {
            return type == TokenType.END
        }
        return this.tokens[this.curr_token].type == type
    }

    fun expect(type:TokenType, msg:String) {
        t = advance()
        assert(t.type == type, msg)
        return t.value
    }

    fun skip_ws() {
        while(check(TokenType.WS)) {
            ~advance()
        }
    }

    fun __String() {
        txt = "["
        first = true
        for (t: this.tokens) {
            if (not first)
                txt ++= ", "
            txt ++= t
            first = false
        }
        txt ++= "]"
        return txt
    }
}

space {

fun letter2piece(l:String, white:Bool) {
    switch(l) {
        case "p": return white ? Pieces.w_pawn : Pieces.b_pawn
        case "K": return white ? Pieces.w_king : Pieces.b_king
        case "Q": return white ? Pieces.w_queen : Pieces.b_queen
        case "B": return white ? Pieces.w_bishop : Pieces.b_bishop
        case "R": return white ? Pieces.w_rook : Pieces.b_rook
        case "N": return white ? Pieces.w_knight : Pieces.b_knight
        default: assert(false, f"Unknown piece: '{l}'")
    }
    return nil
}

fun parse_move(scanner:PGNScanner, white:Bool) {
    if (scanner.check(TokenType.SHORT_CASTLE)) {
        ~scanner.advance()
        // TODO
        return nil
    }
    if (scanner.check(TokenType.LONG_CASTLE)) {
        ~scanner.advance()
        // TODO
        return nil
    }
    piece = nil
    column1 = nil
    column2 = nil
    row1 = nil
    row2 = nil
    takes = false
    promotion_piece = nil
    check = false
    mate = false
    if (scanner.check(TokenType.PIECE)) {
        t = scanner.advance()
        assert(t.value != "p", "p should not be in PGN")
        piece = letter2piece(t.value, true)
    }
    if (scanner.check(TokenType.COLUMN)) {
        column1 = scanner.advance().value
        if (scanner.check(TokenType.COLUMN)) {
            assert(piece != nil, "Piece specification without piece")
            column2 = scanner.advance().value
        }
    }
    if (scanner.check(TokenType.ROW)) {
        if (column1 == nil) {
            assert(piece != nil, "Piece specification without piece")
            row1 = scanner.advance().value
            column2 = scanner.expect(TokenType.COLUMN, "Expected target square (column) after piece specification")
            row2 = scanner.expect(TokenType.ROW, "Expected target square (row) after piece specification")
        } else if (column2 == nil) {
            row1 = scanner.advance().value
        } else
            row2 = scanner.advance().value
    }
    if (scanner.check(TokenType.TAKES)) {
        assert(column1 != nil or row1 != nil or piece != nil, "takes without specifying who")
        ~scanner.advance()
        takes = true
        column2 = scanner.expect(TokenType.COLUMN, "Expected target square (column) after 'x'")
        row2 = scanner.expect(TokenType.ROW, "Expected target square (row) after 'x'")
    }
    if (scanner.check(TokenType.PROMOTION)) {
        assert(column1 != nil or row1 != nil or piece != nil, "promotes without specifying who")
        ~scanner.advance()
        promotion_piece = scanner.expect(TokenType.PIECE, "Expecting piece name after promotion")
    }
    if (scanner.check(TokenType.CHECK)) {
        ~scanner.advance()
        check = true
    }
    if (scanner.check(TokenType.MATE)) {
        ~scanner.advance()
        mate = true
    }
    // TODO: Convert to Move
    notation = ""
    notation ++= piece != nil ? piece : ""
    notation ++= column1 != nil ? column1 : ""
    notation ++= row1 != nil ? row1 : ""
    notation ++= takes ? "x" : ""
    notation ++= column2 != nil ? column2 : ""
    notation ++= row2 != nil ? row2 : ""
    if (promotion_piece != nil) {
        notation ++= "="++promotion_piece
    }
    notation ++= check ? "+" : ""
    notation ++= mate ? "#" : ""
    return notation
}

}

fun parse_pgn(game:String) {
    // TODO: Remove tags
    // TODO: Remove comments
    scanner = pgn.PGNScanner(game)
    moves = []
    result = Game.Result.NOT_FINISHED
    // Parse tokens
    while (not scanner.check(TokenType.END)) {
        ~scanner.skip_ws()
        if (scanner.check(TokenType.MOVE_NUMBER)) {
            // Assert move number?
            ~scanner.advance()
            ~scanner.skip_ws()
            ~moves.append(parse_move(scanner, true))
            ~scanner.expect(TokenType.WS, "Expected white space after move")
            ~scanner.skip_ws()
            if (scanner.check(TokenType.END))
                break
            ~moves.append(parse_move(scanner, false))
        } else if (scanner.check(TokenType.RESULT)) {
            t = scanner.advance()
            switch(t.value) {
                case "*": result = Game.Result.NOT_FINISHED
                case "1-0": result = Game.Result.WHITE_WIN
                case "0-1": result = Game.Result.BLACK_WIN
                case "1/2-1/2": result = Game.Result.DRAW
                default: assert(false, "Incorrect result in RESULT")
            }
        } else {
            assert(false, "Misplaced token: "++scanner.advance())
        }
    }
    return Game(moves, result)
}

}