// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::process::Command;
use std::time::SystemTime;
use std::{fs, thread, vec};
use tauri::Manager;

static WORKING_DIR_PATH: &'static str = "/tmp/ohroniasz";

// TODO: This could be multithreaded.
fn concat_video_files(src_list_path: &str, output_path: &str) {
    Command::new("ffmpeg")
        .arg("-y")
        .arg("-f")
        .arg("concat")
        .arg("-safe")
        .arg("0")
        .arg("-i")
        .arg(src_list_path)
        .arg("-c")
        .arg("copy")
        .arg(output_path)
        .output()
        .expect("ffmpeg failed");
}

fn generate_preview_files_for_directory(directory_path: &str) {
    let time_start = SystemTime::now();

    let positions = ["front", "back", "left_repeater", "right_repeater"];
    let mut workers = vec![];

    for position in positions {
        let mut files: Vec<String> = vec![];

        let dir_entries = fs::read_dir(directory_path).unwrap();
        for dir_entry in dir_entries {
            let dir_entry = dir_entry.unwrap();
            let path = dir_entry.path().clone();
            let file_name = dir_entry.file_name().into_string().unwrap();

            if file_name.contains(position) {
                files.push(path.to_str().unwrap().to_owned());
            }
        }

        files.sort();

        let list_file_content: String = files
            .iter()
            .map(|file_path| format!("file '{file_path}'"))
            .collect::<Vec<_>>()
            .join("\n");

        let src_list_path = format!("{WORKING_DIR_PATH}/list-{position}.txt");
        fs::write(&src_list_path, &list_file_content).unwrap();

        workers.push(thread::spawn(move || {
            let output_path = format!("{WORKING_DIR_PATH}/{position}.mp4");
            concat_video_files(&src_list_path, &output_path);
        }));
    }

    for worker in workers {
        let _ = worker.join();
    }

    let time_end = SystemTime::now();
    let processing_time = time_end
        .duration_since(time_start)
        .expect("Time went backwards")
        .as_millis();

    println!("Generating video files took {processing_time} ms");
}

fn create_working_dir() {
    fs::create_dir_all(&WORKING_DIR_PATH).expect("Could not create app working directory");
}

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
