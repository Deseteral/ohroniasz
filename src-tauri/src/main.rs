// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod config;
mod library_scanner;
mod video_processing;

use config::create_working_dir;
use library_scanner::{scan_library, CamEvent};
use tauri::{api::dialog::blocking::FileDialogBuilder, Manager};

#[tauri::command]
async fn select_and_scan_library() -> Option<Vec<CamEvent>> {
    FileDialogBuilder::new()
        .pick_folder()
        .map(|tesla_cam_path| scan_library(&tesla_cam_path))
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
        .invoke_handler(tauri::generate_handler![select_and_scan_library])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
