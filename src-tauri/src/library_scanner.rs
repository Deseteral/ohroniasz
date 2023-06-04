use std::{
    fs,
    path::{Path, PathBuf},
    vec,
};

use serde::Serialize;

#[derive(Serialize)]
pub struct CamEvent {
    date: String,
    path: PathBuf,
    kind: CamEventKind,
}

#[derive(Serialize)]
enum CamEventKind {
    SavedClip,
    SentryClip,
}

pub fn scan_library(library_path: &Path) -> Vec<CamEvent> {
    let saved_clips_path = library_path.join("SavedClips");
    let sentry_clips_path = library_path.join("SentryClips");

    let mut events: Vec<CamEvent> = vec![];

    for dir_entry in fs::read_dir(&saved_clips_path).unwrap() {
        let dir_entry = dir_entry.unwrap();
        let path = dir_entry.path().clone();

        if path.is_file() {
            continue;
        }

        let dir_name = dir_entry.file_name().into_string().unwrap();

        events.push(CamEvent {
            date: dir_name,
            path,
            kind: CamEventKind::SavedClip,
        });
    }

    for dir_entry in fs::read_dir(&sentry_clips_path).unwrap() {
        let dir_entry = dir_entry.unwrap();
        let path = dir_entry.path().clone();

        if path.is_file() {
            continue;
        }

        let dir_name = dir_entry.file_name().into_string().unwrap();

        events.push(CamEvent {
            date: dir_name,
            path,
            kind: CamEventKind::SentryClip,
        });
    }

    events.sort_by(|a, b| b.date.cmp(&a.date));

    events
}
