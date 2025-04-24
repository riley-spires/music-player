package main

import "core:fmt"
import tfd "tinyfiledialogs/tinyfiledialogs-generated-bindings"
import rl "vendor:raylib"

BACKGROUND_COLOR : rl.Color : {85, 85, 85, 255}
PLAY_PAUSE_COLOR : rl.Color : {155, 155, 155, 200}
PROGRESS_BAR_COLOR : rl.Color : {255, 120, 120, 255}

State :: struct {
    center : struct { x, y: f32},
    percent, progress: f32,
    height, width: i32
}

main :: proc() {
    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(1280, 720, "Music Player")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    rl.InitAudioDevice()

    music : rl.Music = {}
    music_length : f32
    offset : f32 = 50
    previous_progress : f32
    
    for !rl.WindowShouldClose() {
        state := get_current_state(music, music_length)

        rl.BeginDrawing()

        render(&music, state.center.x, state.center.y, offset, state.percent, state.height, state.width)

        rl.EndDrawing()
        rl.UpdateMusicStream(music)

        handle_input(&music, state, &music_length)

        if state.progress < previous_progress {
            rl.PauseMusicStream(music)
            previous_progress = state.progress
        }

        if rl.IsMusicStreamPlaying(music) {
            previous_progress = state.progress
        }
    }
}

handle_input :: proc(music: ^rl.Music, state: State, music_length: ^f32) {
    if rl.IsKeyPressed(rl.KeyboardKey.O) {
        file_name := tfd.tinyfd_openFileDialog("Select your Music", nil, 0, {} ,nil, 0)

        if file_name == nil {
            return
        }

        music^ = rl.LoadMusicStream(file_name)
        for !rl.IsMusicReady(music^) {}
        rl.PlayMusicStream(music^)
        music_length^ = rl.GetMusicTimeLength(music^)
    }   

    if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
        if rl.IsMusicStreamPlaying(music^) {
            rl.PauseMusicStream(music^)
        } else {
            rl.ResumeMusicStream(music^)
        }
    }

}

get_current_state :: proc(music: rl.Music, music_length: f32) -> State {
    current_progress := rl.GetMusicTimePlayed(music)
    percent := current_progress / music_length
    width := rl.GetScreenWidth()
    height := rl.GetScreenHeight()
    center_x := cast(f32) width / 2;
    center_y := cast(f32) height / 2;

    //center : struct { x, y: f32},
    //offset, percent, progress: f32,
    //height, width: i32
    return {{center_x, center_y}, percent, current_progress, height, width}
}

render :: proc(music: ^rl.Music, center_x, center_y, offset, percent: f32, height, width: i32) {
    rl.ClearBackground(BACKGROUND_COLOR)


    if rl.IsMusicStreamPlaying(music^) {
        rl.DrawRectangle(cast(i32)(center_x - offset), cast(i32)(center_y - offset), 50, 100, PLAY_PAUSE_COLOR)
        rl.DrawRectangle(cast(i32)(center_x + offset), cast(i32)(center_y - offset), 50 ,100, PLAY_PAUSE_COLOR)
    } else {
        rl.DrawTriangle({center_x - offset, center_y - offset}, {center_x - offset, center_y + offset}, {center_x + offset, center_y}, PLAY_PAUSE_COLOR)
    }
    rl.DrawRectangle(0, height - cast(i32)offset, cast(i32)(cast(f32)(width) * percent), 50,  PROGRESS_BAR_COLOR)
}
