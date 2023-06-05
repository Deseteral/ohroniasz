use serde::Serialize;
use std::{
    fmt::format,
    fs,
    path::{Path, PathBuf},
    vec,
};
use ts_rs::TS;

#[derive(Serialize, Clone, TS, Debug)]
#[ts(export)]
pub struct CamEvent {
    date: String,
    path: PathBuf,
    kind: CamEventKind,
}

#[derive(Serialize, Clone, TS, Debug)]
#[ts(export)]
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
            date: dir_name_to_date(&dir_name),
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
            date: dir_name_to_date(&dir_name),
            path,
            kind: CamEventKind::SentryClip,
        });
    }

    events.sort_by(|a, b| b.date.cmp(&a.date));

    events
}

fn dir_name_to_date(dir_name: &str) -> String {
    let s: Vec<&str> = dir_name.split("_").collect();
    let d = s[0];
    let t = s[1].replace("-", ":");
    return format!("{d} {t}");
}
