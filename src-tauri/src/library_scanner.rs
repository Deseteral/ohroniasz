use serde::Serialize;
use serde_json::Value;
use std::{
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
    location: CamEventLocation,
}

#[derive(Serialize, Clone, TS, Debug)]
#[ts(export)]
enum CamEventKind {
    SavedClip,
    SentryClip,
}

#[derive(Serialize, Clone, TS, Debug)]
#[ts(export)]
struct CamEventLocation {
    city: String,
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

        let metadata_str = fs::read_to_string(path.join("event.json")).unwrap();
        let metadata: Value = serde_json::from_str(&metadata_str).unwrap();
        let city = metadata["city"].as_str().unwrap().to_string();

        events.push(CamEvent {
            date: dir_name_to_date(&dir_name),
            path,
            kind: CamEventKind::SavedClip,
            location: CamEventLocation { city },
        });
    }

    for dir_entry in fs::read_dir(&sentry_clips_path).unwrap() {
        let dir_entry = dir_entry.unwrap();
        let path = dir_entry.path().clone();

        if path.is_file() {
            continue;
        }

        let dir_name = dir_entry.file_name().into_string().unwrap();

        let metadata_str = fs::read_to_string(path.join("event.json")).unwrap();
        let metadata: Value = serde_json::from_str(&metadata_str).unwrap();
        let city = metadata["city"].as_str().unwrap().to_string();

        events.push(CamEvent {
            date: dir_name_to_date(&dir_name),
            path,
            kind: CamEventKind::SentryClip,
            location: CamEventLocation { city },
        });
    }

    events.sort_by(|a, b| b.date.cmp(&a.date));

    events
}

fn dir_name_to_date(dir_name: &str) -> String {
    let s: Vec<&str> = dir_name.split('_').collect();
    let d = s[0];
    let t = s[1].replace('-', ":");
    format!("{d} {t}")
}
