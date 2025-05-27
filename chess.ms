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

class PGNScanner {
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
                } else if (i+1 < txt.length() && txt[i+1] == ".") {
                    i += 1
                    token = PGNToken(TokenType.MOVE_NUMBER, c++".")
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
            } else if (ord(c) >= 97 and ord(c) <= 104) {
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
        if (curr_token >= this.tokens.length()) {
            return PGNToken(TokenType.END, "")
        }
        t = this.tokens[curr_token]
        curr_token += 1
        return t
    }

    fun check(type:TokenType) {
        if (curr_token >= this.tokens.length()) {
            return false
        }
        return this.tokens[curr_token] == type
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

fun parse_pgn(game:String) {
    // TODO: Remove tags
    // TODO: Remove comments
    scanner = pgn.PGNScanner(game)
    moves = []
    result = Game.Result.NOT_FINISHED
    // Parse tokens
    return Game(moves, result)
}

}