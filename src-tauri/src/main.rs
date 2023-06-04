// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod config;
mod video_processing;

use config::create_working_dir;
use tauri::{api::dialog::blocking::FileDialogBuilder, Manager};

#[derive(serde::Serialize)]
struct CamEvent {
    date: String,
}

#[derive(serde::Serialize)]
struct ViewModel {
    events: Vec<CamEvent>,
}

#[tauri::command]
async fn select_directory() -> Option<ViewModel> {
    FileDialogBuilder::new()
        .pick_folder()
        .map(|_tesla_cam_path| ViewModel { events: vec![] })
}

fn main() {
    create_working_dir();

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
        .invoke_handler(tauri::generate_handler![select_directory])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
