
INCLUDE "defines.asm"

; TILE_OFFSET   EQU _VRAM
; TILE_EMPTY    EQU TILE_OFFSET+0
; TILE_BRICK_L  EQU TILE_OFFSET+8
; TILE_BRICK_R  EQU TILE_OFFSET+9
; TILE_PADDLE_L EQU TILE_OFFSET+12
; TILE_PADDLE_C EQU TILE_OFFSET+13
; TILE_PADDLE_R EQU TILE_OFFSET+14
; TILE_BALL     EQU TILE_OFFSET+15

SECTION "Intro", ROMX

Intro::
InitialiseVariables:
    ld a, 0
    ld [hOAMIndex], a

    ld hl, wPaddlePosition
    ld [hl], LOW((SCRN_X / 2) << 4)
    inc hl
    ld [hl], HIGH((SCRN_X / 2) << 4)
    
TileCopy:
    
    ; Copy the background tile data
    ld de, xTilesetBG
    ld hl, $9000
    ld bc, xTilesetBG.end - xTilesetBG

    call LCDMemcpy

    ; Copy the sprite tile data
    ld de, xTilesetSprites 
    ld hl, $8000
    ld bc, xTilesetSprites.end - xTilesetSprites 

    call LCDMemcpy

    ; Copy the tilemap
    ld de, xTilemap
    ld hl, _SCRN0
    ld bc, xTilemap.end - xTilemap

    call LCDMemcpy

DisplayActivate:
    ; Configure and activate the display
    ld a, LCDCF_ON | LCDCF_OBJON | LCDCF_BGON
    ld [rLCDC], a
    ld [hLCDC], a

GameLoop:
    ; Need to call this every frame to get Metasprites working
    call ResetShadowOAM

    ; Wait for the display to finish updating
    call WaitVBlank

    ; Update the paddle and the OAM bytes
    call SpritePaddleUpdate

    ; Call the DMA subroutine we copied to HRAM,
    ; which then copies the bytes to the OAM and sprites begin to draw
    ld  a, HIGH(wShadowOAM)
    call hOAMDMA

    jr  GameLoop


