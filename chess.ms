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

    fun Game(moves:List) {
        this.moves = moves
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

fun parse_pgn(game:String) {
    // TODO: Remove tags
    // TODO: Remove comments
    move_num = 1
    for (l: game) {
        if (l == move_num++".") {
            
        }
    }
}

}