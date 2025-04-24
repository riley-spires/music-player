package main

import "core:fmt"
import tfd "tinyfiledialogs/tinyfiledialogs-generated-bindings"
import rl "vendor:raylib"

BACKGROUND_COLOR : rl.Color : {85, 85, 85, 255}
PLAY_PAUSE_COLOR : rl.Color : {155, 155, 155, 200}
PROGRESS_BAR_COLOR : rl.Color : {255, 120, 120, 255}

main :: proc() {
    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(1280, 720, "Music Player")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    rl.InitAudioDevice()

    music : rl.Music = {}
    music_length : f32
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        rl.ClearBackground(BACKGROUND_COLOR)

        width := rl.GetScreenWidth()
        height := rl.GetScreenHeight()
        center_x := cast(f32) width / 2;
        center_y := cast(f32) height / 2;
        offset : f32 = 50

        if rl.IsMusicStreamPlaying(music) {
            rl.DrawRectangle(cast(i32)(center_x - offset), cast(i32)(center_y - offset), 50, 100, PLAY_PAUSE_COLOR)
            rl.DrawRectangle(cast(i32)(center_x + offset), cast(i32)(center_y - offset), 50 ,100, PLAY_PAUSE_COLOR)
        } else {
            rl.DrawTriangle({center_x - offset, center_y - offset}, {center_x - offset, center_y + offset}, {center_x + offset, center_y}, PLAY_PAUSE_COLOR)
        }
        current_progress := rl.GetMusicTimePlayed(music)
        percent := current_progress / music_length
        rl.DrawRectangle(0, height - cast(i32)offset, cast(i32)(cast(f32)(width) * percent), 50,  PROGRESS_BAR_COLOR)
        rl.UpdateMusicStream(music)

        if rl.IsKeyPressed(rl.KeyboardKey.O) {
            file_name := tfd.tinyfd_openFileDialog("Select your Music", nil, 0, {} ,nil, 0)

            music = rl.LoadMusicStream(file_name)
            for !rl.IsMusicReady(music) {}
            music.looping = false
            rl.PlayMusicStream(music)
            music_length = rl.GetMusicTimeLength(music)
        }   

        if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
            if rl.IsMusicStreamPlaying(music) {
                rl.PauseMusicStream(music)
            } else {
                rl.ResumeMusicStream(music)
            }
        }

        rl.EndDrawing()

    }
}
