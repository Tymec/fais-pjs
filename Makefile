#!/bin/make -f

default:
	@echo "Please specify a target to build"

tictactoe:
	@tic-tac-toe/game.sh --com

tetris:
	@love.exe tetris

.PHONY: default tetris
