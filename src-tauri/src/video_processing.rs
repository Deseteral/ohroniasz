use crate::config::WORKING_DIR_PATH;
use std::process::Command;
use std::sync::Arc;
use std::time::SystemTime;
use std::{fs, thread, vec};

static CAMERA_POSITIONS: [&'static str; 4] = ["front", "back", "left_repeater", "right_repeater"];

pub fn generate_preview_files_for_directory(directory_path: &str) {
    let time_start = SystemTime::now();

    let directory_path = Arc::new(directory_path.to_string());

    CAMERA_POSITIONS
        .iter()
        .map(|position| {
            let directory_path = Arc::clone(&directory_path);
            thread::spawn(move || generate_video_for_single_camera(&position, &directory_path))
        })
        .for_each(|worker| {
            let _ = worker.join();
        });

    let time_end = SystemTime::now();
    let processing_time = time_end
        .duration_since(time_start)
        .expect("Time went backwards")
        .as_millis();

    println!("Generating video files took {processing_time} ms");
}

fn generate_video_for_single_camera(camera_position: &str, directory_path: &str) {
    let mut files: Vec<String> = vec![];

    // TODO: Re-reading of directory entires for every camera position is unnecessary.
    let dir_entries = fs::read_dir(&directory_path).unwrap();
    for dir_entry in dir_entries {
        let dir_entry = dir_entry.unwrap();
        let path = dir_entry.path().clone();
        let file_name = dir_entry.file_name().into_string().unwrap();

        if file_name.contains(camera_position) {
            files.push(path.to_str().unwrap().to_owned());
        }
    }

    files.sort();

    let list_file_content: String = files
        .iter()
        .map(|file_path| format!("file '{file_path}'"))
        .collect::<Vec<_>>()
        .join("\n");

    let src_list_path = format!("{WORKING_DIR_PATH}/list-{camera_position}.txt");
    fs::write(&src_list_path, &list_file_content).unwrap();

    let video_output_path = format!("{WORKING_DIR_PATH}/{camera_position}.mp4");
    concat_video_files(&src_list_path, &video_output_path);
}

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
