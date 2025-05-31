#!/usr/bin/moss

d"""
App for converting chess games into intstructions for
spacial paintings.
"""

import chess.*

fun format_square(v:Int) {
    if (v > 99)
        return v ++ " "
    else if (v > 9)
        return " " ++ v ++ " "
    else
        return "  " ++ v ++ " "
}

class Canvas {

    fun Canvas() {
        this.squares = [[0 : _ = 0..8] : __ = 0..8]
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
            //this.squares[move.to[1]][move.to[0]] += 1
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