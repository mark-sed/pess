#!/usr/bin/moss

d"""
App for converting chess games into instructions for
spacial paintings.
"""

import chess.*

class Color {
    fun Color(a:Int=0, r:Int=0, g:Int=0, b:Int=0) {
        this.a = a
        this.r = r
        this.g = g
        this.b = b
    }

    fun (+)(v) {
        return Color(this.a + v*20, this.r, this.g, this.b) // TODO: remove multiplier
    }

    // TODO: Normalize function to put values into 0-255 range.

    fun hexc(v) {
        s = hex(v)[2..4]
        if (s.length() == 1)
            return "0"++s
        return s
    }

    fun __String() {
        return this.hexc(this.r) ++ this.hexc(this.g) ++ this.hexc(this.b) ++ this.hexc(this.a)
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
                this.squares[move.to[1]][move.to[0]].r += 190
                this.squares[move.to[1]][move.to[0]].b += 255
                this.squares[move.to[1]][move.to[0]] += 10
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
        if (move.check) {
            this.squares[move.to[1]][move.to[0]].r += 190
            this.squares[move.to[1]][move.to[0]].b += 255
            this.squares[move.to[1]][move.to[0]] += 10
        }
    }

    fun to_html() {
        s = this.squares
        width = 100
        return Note(f"""
        <svg xmlns="http://www.w3.org/2000/svg" width="{width*8}" height="{width*8}" viewBox="0 0 {width*8} {width*8}">
        <g id="board">  
            <!-- Draw bottom row first (y = width*7 - row*width) -->

            <!-- Row 7 (top) -->
            <rect x="{0*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][0]}"/>
            <rect x="{1*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][1]}"/>
            <rect x="{2*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][2]}"/>
            <rect x="{3*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][3]}"/>
            <rect x="{4*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][4]}"/>
            <rect x="{5*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][5]}"/>
            <rect x="{6*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][6]}"/>
            <rect x="{7*width}" y="{0*width}" width="{width}" height="{width}" fill="#{s[7][7]}"/>

            <!-- Row 6 -->
            <rect x="{0*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][0]}"/>
            <rect x="{1*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][1]}"/>
            <rect x="{2*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][2]}"/>
            <rect x="{3*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][3]}"/>
            <rect x="{4*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][4]}"/>
            <rect x="{5*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][5]}"/>
            <rect x="{6*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][6]}"/>
            <rect x="{7*width}" y="{1*width}" width="{width}" height="{width}" fill="#{s[6][7]}"/>

            <!-- Row 5 -->
            <rect x="{0*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][0]}"/>
            <rect x="{1*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][1]}"/>
            <rect x="{2*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][2]}"/>
            <rect x="{3*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][3]}"/>
            <rect x="{4*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][4]}"/>
            <rect x="{5*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][5]}"/>
            <rect x="{6*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][6]}"/>
            <rect x="{7*width}" y="{2*width}" width="{width}" height="{width}" fill="#{s[5][7]}"/>

            <!-- Row 4 -->
            <rect x="{0*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][0]}"/>
            <rect x="{1*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][1]}"/>
            <rect x="{2*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][2]}"/>
            <rect x="{3*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][3]}"/>
            <rect x="{4*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][4]}"/>
            <rect x="{5*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][5]}"/>
            <rect x="{6*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][6]}"/>
            <rect x="{7*width}" y="{3*width}" width="{width}" height="{width}" fill="#{s[4][7]}"/>

            <!-- Row 3 -->
            <rect x="{0*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][0]}"/>
            <rect x="{1*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][1]}"/>
            <rect x="{2*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][2]}"/>
            <rect x="{3*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][3]}"/>
            <rect x="{4*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][4]}"/>
            <rect x="{5*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][5]}"/>
            <rect x="{6*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][6]}"/>
            <rect x="{7*width}" y="{4*width}" width="{width}" height="{width}" fill="#{s[3][7]}"/>

            <!-- Row 2 -->
            <rect x="{0*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][0]}"/>
            <rect x="{1*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][1]}"/>
            <rect x="{2*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][2]}"/>
            <rect x="{3*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][3]}"/>
            <rect x="{4*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][4]}"/>
            <rect x="{5*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][5]}"/>
            <rect x="{6*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][6]}"/>
            <rect x="{7*width}" y="{5*width}" width="{width}" height="{width}" fill="#{s[2][7]}"/>

            <!-- Row 1 -->
            <rect x="{0*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][0]}"/>
            <rect x="{1*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][1]}"/>
            <rect x="{2*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][2]}"/>
            <rect x="{3*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][3]}"/>
            <rect x="{4*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][4]}"/>
            <rect x="{5*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][5]}"/>
            <rect x="{6*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][6]}"/>
            <rect x="{7*width}" y="{6*width}" width="{width}" height="{width}" fill="#{s[1][7]}"/>

            <!-- Row 0 (bottom) -->
            <rect x="{0*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][0]}"/>
            <rect x="{1*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][1]}"/>
            <rect x="{2*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][2]}"/>
            <rect x="{3*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][3]}"/>
            <rect x="{4*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][4]}"/>
            <rect x="{5*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][5]}"/>
            <rect x="{6*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][6]}"/>
            <rect x="{7*width}" y="{7*width}" width="{width}" height="{width}" fill="#{s[0][7]}"/>
        </g>
        </svg>
        """, "html")
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

if (args.length() != 1) {
    exit("Error: Program takes path to pgn file.\n")
}

game_notation = with_open(args[0], fun(f)="\n".join(f.readlines()))
game = pgn.parse_pgn(game_notation)

board = Board(game)
canvas = Canvas()
~canvas.draw_starting(board)

for (i : 0..game.moves.length()) {
    ~canvas.draw_dst_move(game.moves[board.index])
    ~board.move()
    ~print(board)
    ~print(canvas)
    //~input()
}

~print(canvas)
~print(board)

canvas.to_html()
Note("<b>"++args[0]++"</b>", "html")
game_notation
