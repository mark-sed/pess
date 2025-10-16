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
        return Color(this.a + v, this.r, this.g, this.b) // TODO: remove multiplier
    }

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
    fun Canvas(color_check:Bool=false, color_castle:Bool=false) {
        this.squares = []
        for (x: 0..8) {
            ~this.squares.append([Color() : _ = 0..8])
        }

        this.color_check = color_check
        this.color_castle = color_castle
    }

    // Normalize function to put values into 0-255 range.
    fun normalize() {
        flatten = []
        for (row: this.squares) {
            for (v: row) {
                ~flatten.append(v.r, v.g, v.b, v.a)
            }
        }

        vmin = min(flatten)
        vmax = max(flatten)

        for (row: 0..this.squares.length()) {
            for (col: 0..this.squares.length()) {
                c = this.squares[row][col]
                r = Int((c.r - vmin) * 255 / (vmax - vmin))
                g = Int((c.g - vmin) * 255 / (vmax - vmin))
                b = Int((c.b - vmin) * 255 / (vmax - vmin))
                a = Int((c.a - vmin) * 255 / (vmax - vmin))
                this.squares[row][col] = Color(a, r, g, b)
            }
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

    fun check_colorize(x, y) {
        this.squares[x][y].r += 1
        this.squares[x][y].b += 2
        this.squares[x][y] += 1
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
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    // Determine direction and step
                    if (dr > 0)
                        step_r = 1
                    else if (dr < 0)
                        step_r = -1
                    else
                        step_r = 0

                    if (dc > 0)
                        step_c = 1
                    else if (dc < 0)
                        step_c = -1
                    else
                        step_c = 0

                    // Verify it's a valid pawn move (1 or 2 forward, or 1 diagonal)
                    if (not ((Math.abs(dc) <= 1) && (Math.abs(dr) <= 2) && (Math.abs(dr) >= 1)))
                        raise ValueError("Not a valid pawn move")

                    // Move step by step until reaching the destination
                    r = sr
                    c = sc
                    while ([r, c] != [er + step_r, ec + step_c]) {
                        this.squares[r][c] += 1
                        if ([r, c] == [er, ec])
                            break
                        r += step_r
                        c += step_c
                    }
                }
                case Pieces.w_queen, Pieces.b_queen: {
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    if (dr > 0)
                        step_r = 1
                    else if (dr < 0)
                        step_r = -1
                    else
                        step_r = 0

                    if (dc > 0)
                        step_c = 1
                    else if (dc < 0)
                        step_c = -1
                    else
                        step_c = 0

                    // Verify that it's a valid queen move (same row, column, or diagonal)
                    if (not (sr == er || sc == ec || Math.abs(dr) == Math.abs(dc)))
                        raise ValueError("Not a valid queen move")

                    // Move step by step until reaching the end square
                    r = sr
                    c = sc
                    while ([r, c] != [er + step_r, ec + step_c]) {
                        this.squares[r][c] += 1
                        if (this.color_check && move.check) {
                            ~this.check_colorize(r, c)
                        }
                        if ([r, c] == [er, ec])
                            break
                        r += step_r
                        c += step_c
                    }
                }
                case Pieces.w_bishop, Pieces.b_bishop: {
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    if (dr > 0)
                        step_r = 1
                    else if (dr < 0)
                        step_r = -1
                    else
                        step_r = 0

                    if (dc > 0)
                        step_c = 1
                    else if (dc < 0)
                        step_c = -1
                    else
                        step_c = 0

                    // Verify that it's a valid bishop move (must be diagonal)
                    if (Math.abs(dr) != Math.abs(dc))
                        raise ValueError("Not a valid bishop move")

                    // Move step by step until reaching the end square
                    r = sr
                    c = sc
                    while ([r, c] != [er + step_r, ec + step_c]) {
                        this.squares[r][c] += 1
                        if (this.color_check && move.check) {
                            ~this.check_colorize(r, c)
                        }
                        if ([r, c] == [er, ec])
                            break
                        r += step_r
                        c += step_c
                    }
                }
                case Pieces.w_rook, Pieces.b_rook: {
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    if (dr > 0)
                        step_r = 1
                    else if (dr < 0)
                        step_r = -1
                    else
                        step_r = 0

                    if (dc > 0)
                        step_c = 1
                    else if (dc < 0)
                        step_c = -1
                    else
                        step_c = 0

                    // Verify that it's a valid rook move (same row or same column)
                    if (not (sr == er || sc == ec))
                        raise ValueError("Not a valid rook move")

                    // Move step by step until reaching the end square
                    r = sr
                    c = sc
                    while ([r, c] != [er + step_r, ec + step_c]) {
                        this.squares[r][c] += 1
                        if (this.color_check && move.check) {
                            ~this.check_colorize(r, c)
                        }
                        if ([r, c] == [er, ec])
                            break
                        r += step_r
                        c += step_c
                    }
                }
                case Pieces.w_king, Pieces.b_king: {
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    if (dr > 0)
                        step_r = 1
                    else if (dr < 0)
                        step_r = -1
                    else
                        step_r = 0

                    if (dc > 0)
                        step_c = 1
                    else if (dc < 0)
                        step_c = -1
                    else
                        step_c = 0

                    // Verify that it's a valid king move (one square in any direction)
                    if (Math.abs(dr) > 1 || Math.abs(dc) > 1)
                        raise ValueError("Not a valid king move")

                    // Move only one step
                    r = sr + step_r
                    c = sc + step_c
                    this.squares[r][c] += 1
                }
                case Pieces.w_knight, Pieces.b_knight: {
                    sc, sr = move.from
                    ec, er = move.to

                    dr = er - sr
                    dc = ec - sc

                    // Verify it's a valid knight move (L-shape)
                    if (not ((Math.abs(dr) == 2 && Math.abs(dc) == 1) || (Math.abs(dr) == 1 && Math.abs(dc) == 2)))
                        raise ValueError("Not a valid knight move")

                    // Determine the L-path step directions
                    if (dr != 0)
                        step_r = (dr > 0) ? 1 : -1
                    else
                        step_r = 0

                    if (dc != 0)
                        step_c = (dc > 0) ? 1 : -1
                    else
                        step_c = 0

                    // Apply path along L: first move along the longer leg
                    r = sr
                    c = sc
                    this.squares[r][c] += 1
                    if (Math.abs(dr) == 2) {
                        // move two steps in row direction
                        for (i : 1..3) {
                            r += step_r
                            this.squares[r][c] += 1
                        }
                        // move one step in column direction
                        c += step_c
                        this.squares[r][c] += 1
                    } else {
                        // move two steps in column direction
                        for (i : 1..3) {
                            c += step_c
                            this.squares[r][c] += 1
                        }
                        // move one step in row direction
                        r += step_r
                        this.squares[r][c] += 1
                    }
                }
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
        if (this.color_check && move.check) {
            ~this.check_colorize(move.to[1], move.to[0])
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
canvas = Canvas(true, true)
//~canvas.draw_starting(board)

for (i : 0..game.moves.length()) {
    ~canvas.draw_full_move(game.moves[board.index])
    ~board.move()
    ~print(board)
    ~print(canvas)
    //~input()
}

~print(canvas)
~print(board)

~canvas.normalize()
canvas.to_html()
Note("<b>"++args[0]++"</b>", "html")
game_notation
