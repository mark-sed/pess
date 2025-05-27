#!/usr/bin/moss

d"""
App for converting chess games into intstructions for
spacial paintings.
"""

import chess.*

moves = [
    Move([1, 4], [3, 4], Pieces.w_pawn, "e4"),
    Move([6, 4], [4, 4], Pieces.b_pawn, "e5"),
    Move([1, 3], [3, 3], Pieces.w_pawn, "d4"),
    Move([7, 6], [5, 5], Pieces.b_knight, "Nf6"),
]

game = Game(moves)
game

board = Board(game)
board

"\n"
~board.move(100)
board