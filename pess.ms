#!/usr/bin/moss

d"""
App for converting chess games into instructions for
spacial paintings.
"""

import chess.*

class Color {
    fun Color(a:Int=255, r:Int=0, g:Int=0, b:Int=0) {
        this.a = a
        this.r = r
        this.g = g
        this.b = b
    }

    fun (+)(v) {
        return Color(this.a, this.r + v, this.g + v, this.b + v)
    }

    fun __String() {
        rgba = lshift((this.r and 0xFF), 24) or lshift((this.g and 0xFF), 16) or lshift((this.b and 0xFF), 8) or (this.a and 0xFF)
        return hex(rgba)
    }
}

fun format_square(v:Color) {
    x = String(v)
    pad_total = 12 - x.length()
    left = pad_total / 2
    right = pad_total - left

    return (" " * left) ++ x ++ (" " * right)
}

class Canvas {

    fun Canvas() {
        this.squares = []
        for (x: 0..8) {
            ~this.squares.append([Color() : _ = 0..8])
        }
    }

    fun draw_starting(board:Board) {
        brd = board.board
        row = 0
        for (r: brd[-1..-brd.length()-1]) {
            col = 0
            for (p: r) {
                if (p != nil)
                    this.squares[row][col] += 1
                col += 1
            }
            row += 1
        }
    }

    fun draw_full_move(move:Move) {
        if (move.castle) {
            if (move.short and move.white) {
                this.squares[0][4] += 1
                this.squares[0][5] += 2
                this.squares[0][6] += 2
                this.squares[0][7] += 1
            } else if (not move.short and move.white) {
                this.squares[0][0] += 1
                this.squares[0][1] += 1
                this.squares[0][2] += 2
                this.squares[0][3] += 2
                this.squares[0][4] += 1
            } else if (move.short and not move.white) {
                this.squares[7][4] += 1
                this.squares[7][5] += 2
                this.squares[7][6] += 2
                this.squares[7][7] += 1
            } else {
                this.squares[7][0] += 1
                this.squares[7][1] += 1
                this.squares[7][2] += 2
                this.squares[7][3] += 2
                this.squares[7][4] += 1
            }   
        } else {
            piece = move.piece
            switch (piece) {
                case Pieces.w_pawn, Pieces.b_pawn: {
                    off = is_white(piece) ? 1 : -1
                    for (row : move.from[1]+off..move.to[1]+off) {
                        this.squares[row][move.to[0]] += 1
                    }
                }
                // TODO:
            }
            if (move.check) {
                this.squares[move.to[1]][move.to[0]].r += 40
            }
        }
    }

    fun draw_dst_move(move:Move) {
        if (move.castle) {
            if (move.short and move.white) {
                this.squares[0][6] += 1
                this.squares[0][5] += 1
            } else if (not move.short and move.white) {
                this.squares[0][2] += 1
                this.squares[0][3] += 1
            } else if (move.short and not move.white) {
                this.squares[7][6] += 1
                this.squares[7][5] += 1
            } else {
                this.squares[7][2] += 1
                this.squares[7][3] += 1
            }   
        } else {
            this.squares[move.to[1]][move.to[0]] += 1
        }
    }

    fun __String() {
        txt = ""
        for (row: this.squares[-1..-this.squares.length()-1]) {
            for (p: row) {
                txt ++= format_square(p)
            }
            txt ++= "\n"
        }
        return txt
    }
}

game = pgn.parse_pgn("""
1.e4 Nf6 2.e5 Nd5 3.d4 d6 4.Nf3 g6 5.Bc4 Nb6 6.Bb3 Bg7 7.Qe2
Nc6 8.O-O O-O 9.h3 a5 10.a4 dxe5 11.dxe5 Nd4 12.Nxd4 Qxd4
13.Re1 e6 14.Nd2 Nd5 15.Nf3 Qc5 16.Qe4 Qb4 17.Bc4 Nb6 18.b3
Nxc4 19.bxc4 Re8 20.Rd1 Qc5 21.Qh4 b6 22.Be3 Qc6 23.Bh6 Bh8
24.Rd8 Bb7 25.Rad1 Bg7 26.R8d7 Rf8 27.Bxg7 Kxg7 28.R1d4 Rae8
29.Qf6+ Kg8 30.h4 h5 31.Kh2 Rc8 32.Kg3 Rce8 33.Kf4 Bc8 34.Kg5
1-0""")

board = Board(game)
canvas = Canvas()
~canvas.draw_starting(board)

for (i : 0..game.moves.length()) {
    ~canvas.draw_full_move(game.moves[board.index])
    ~board.move()
    board
    "\n"
    canvas
    "\n"
    input()
}

canvas
"\n"

board
"\n"