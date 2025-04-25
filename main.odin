package main

import "core:fmt"
import "core:strings"

import tfd "tinyfiledialogs/tinyfiledialogs-generated-bindings"
import rl "vendor:raylib"

BACKGROUND_COLOR : rl.Color : {85, 85, 85, 255}
PLAY_PAUSE_COLOR : rl.Color : {155, 155, 155, 200}
PROGRESS_BAR_COLOR : rl.Color : {255, 120, 120, 255}

ApplicationStatus :: enum {
    UNLOADED,
    LOADED
}

State :: struct {
    status: ApplicationStatus,
    music: rl.Music,
    loaded_files: [dynamic]string,
    current_file: string,
    center : struct { x, y: f32},
    length, percent, progress, previous_progress: f32,
    height, width: i32
}

main :: proc() {
    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(1280, 720, "Music Player")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    rl.InitAudioDevice()

    state := init()
    defer cleanup(&state)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        render(state)

        rl.EndDrawing()
        rl.UpdateMusicStream(state.music)

        handle_input(&state)

        if state.progress < state.previous_progress {
            rl.PauseMusicStream(state.music)
            state.previous_progress = state.progress
        }

        if rl.IsMusicStreamPlaying(state.music) {
            state.previous_progress = state.progress
        }

        update(&state)
    }

}

cleanup :: proc(state: ^State) {
    for file in state.loaded_files {
        delete(file)
    }
    delete(state.loaded_files)
}

load_music :: proc(state: ^State) {
    filters := []cstring{ "*.mp3", "*.wav", "*.ogg", "*.qoa", "*.xm", "*.mod", "*.flac" }
    file_name := tfd.tinyfd_openFileDialog("Select your Music", nil, i32(len(filters)), &filters[0], nil, 0)

    if file_name == nil {
        return
    }

    state.music = rl.LoadMusicStream(file_name)
    for !rl.IsMusicReady(state.music) {}

    state.status = ApplicationStatus.LOADED
    state.length = rl.GetMusicTimeLength(state.music)

    rl.PlayMusicStream(state.music)

    file_str := strings.clone_from_cstring(file_name)

    state.current_file = file_str

    append(&state.loaded_files, file_str)
}

toggle_music :: proc(state: ^State) {
    if rl.IsMusicStreamPlaying(state.music) {
        rl.PauseMusicStream(state.music)
    } else {
        rl.ResumeMusicStream(state.music)
    }
}

handle_input :: proc(state: ^State) {
    // Make buttons invisible
    rl.GuiSetAlpha(0)

    // Always wanted keybinds
    if rl.IsKeyPressed(rl.KeyboardKey.O) {
        load_music(state)
    }   

    // Keybinds depending upon application status
    // Center button
    x := state.center.x - 50
    y := state.center.y - 50
    height := state.center.y + 50 - y
    width := state.center.x + 50 - x
    switch state.status {
        case ApplicationStatus.UNLOADED:
            if rl.GuiButton({x, y, width, height}, "") {
                load_music(state)
            }
        case ApplicationStatus.LOADED:
            if rl.GuiButton({x, y, width, height}, "") {
                toggle_music(state)
            }
    }
}

init :: proc() -> State {
    height := rl.GetScreenHeight()
    width := rl.GetScreenWidth()
    return {
        status = ApplicationStatus.UNLOADED,
        music = {},
        loaded_files = make([dynamic]string, 0, 32),
        center = { f32(width) / 2, f32(height) / 2 },
        length = 0, percent = 0, progress = 0, previous_progress = 0,
        height = height, width = width
    }
}

update :: proc(state: ^State) {
    state.progress = rl.GetMusicTimePlayed(state.music)
    state.percent = state.progress / state.length
    state.width = rl.GetScreenWidth()
    state.height = rl.GetScreenHeight()
    state.center = { x = f32(state.width) / 2, y = f32(state.height) / 2}
}

render :: proc(state: State) {
    offset : f32 = 50
    draw_play :: proc(state: State, offset: f32) {
        rl.DrawTriangle({state.center.x - offset, state.center.y - offset}, {state.center.x - offset, state.center.y + offset}, {state.center.x + offset, state.center.y}, PLAY_PAUSE_COLOR)
    }
    draw_pause :: proc(state: State, offset: f32) {
        rl.DrawRectangle(i32(state.center.x - offset), i32(state.center.y - offset), 50, 100, PLAY_PAUSE_COLOR)
        rl.DrawRectangle(i32(state.center.x + offset), i32(state.center.y - offset), 50 ,100, PLAY_PAUSE_COLOR)
    }

    rl.ClearBackground(BACKGROUND_COLOR)
    FONT_SIZE :: 25
    FONT_PADDING :: 5

    switch state.status {
        case ApplicationStatus.UNLOADED:
            draw_play(state, offset)
        case ApplicationStatus.LOADED:
            c_file := strings.clone_to_cstring(state.current_file)
            defer delete(c_file)
            rl.DrawText(c_file, 0 + FONT_PADDING, 0 + FONT_PADDING, FONT_SIZE, PLAY_PAUSE_COLOR)

            if rl.IsMusicStreamPlaying(state.music) {
                draw_pause(state, offset)
            } else {
                draw_play(state, offset)
            }
    }

    rl.DrawRectangle(0, state.height - i32(offset), i32(f32(state.width) * state.percent), i32(offset),  PROGRESS_BAR_COLOR)
}
