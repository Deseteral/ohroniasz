// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod config;
mod video_processing;

use config::create_working_dir;
use tauri::Manager;
use video_processing::generate_preview_files_for_directory;

fn main() {
    create_working_dir();

    generate_preview_files_for_directory(
        "/Users/deseteral/Downloads/TeslaCam/SavedClips/2023-05-29_14-09-51",
    );

    tauri::Builder::default()
        .setup(|app| {
            #[cfg(debug_assertions)]
            {
                let window = app.get_window("main").unwrap();
                window.open_devtools();
                window.close_devtools();
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
