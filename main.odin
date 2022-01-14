package engine

import "core:time"
import "core:fmt"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "perf"
import "log"
import "renderer"
import "trace"

window : glfw.WindowHandle
update_count: int

main :: proc() {
    when ODIN_DEBUG {
        log.should_log_to_console(true)
        log.should_log_to_file(true)
        trace.init()
        defer trace.stop()
    }
    log.write("Starting")
    
    glfw.Init()
    
    res_x, res_y : i32 = 800,600

    log.write("Creating window", res_x, "x", res_y)
    window = glfw.CreateWindow(res_x, res_y, "Batch Renderer", nil, nil)
    glfw.MakeContextCurrent(window)
    glfw.SetKeyCallback(window, key_callback)
    glfw.SetFramebufferSizeCallback(window, size_callback)

    if window == nil {
        log.write("Unable to create window")
        return
    }

    ok := renderer.init()
    if !ok {
        log.write("Unable to initialize renderer")
        return
    }

    ok = init()
    if !ok {
        log.write("Unable to initialize game")
    }

    previous_time := f32(glfw.GetTime())

    for !glfw.WindowShouldClose(window) {
        new_time := f32(glfw.GetTime())
        update(new_time - previous_time)
        renderer.draw()

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }

}

init :: proc() -> bool {
    trace.proc_start()
    defer trace.proc_end()
    
    log.write("Init")

    return true
}

update :: proc(dt: f32) {
    trace.proc_start()
    defer trace.proc_end()

    perf.start_update()
    defer perf.end_update()

    if update_count % 10 == 0 {
        perf.write_stats()
    }

    update_count += 1
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, modes: i32) {
    if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}