#!/bin/make -f

default:
	@echo "Please specify a target to build"

clean:
	@rm -rf build

tictactoe:
	@tic-tac-toe/game.sh --com

tetris:
	@love.exe tetris

crawler:
	@ruby crawler/main.rb

chatbot:
	@cd chatbot && poetry run python -m app

build/tetris.exe:
	@mkdir -p build
	cd tetris && zip -9 -r ../build/Tetris.love .
	cat $(whereis love.exe) build/Tetris.love > build/Tetris.exe
	rm build/Tetris.love

build/tetris.apk:
	@rm -rf build/love_game
	@mkdir -p build
	apktool d -s -o build/love_game lib/love-11.5-android-embed.apk
	@mkdir -p build/love_game/assets
	cd tetris && zip -9 -r ../build/love_game/assets/game.love .
	yes | cp tetris/AndroidManifest.xml build/love_game/AndroidManifest.xml
	apktool b -o build/Tetris.apk build/love_game
	uberapk --apks build/Tetris.apk --overwrite
	rm -rf build/love_game

.PHONY: default clean tetris crawler chatbot build/tetris.exe build/tetris.apk