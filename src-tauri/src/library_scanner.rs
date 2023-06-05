use serde::Serialize;
use serde_json::Value;
use std::{
    fs::{self, DirEntry},
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
        if let Some(cam_event) = dir_entry_to_cam_event(dir_entry, CamEventKind::SavedClip) {
            events.push(cam_event);
        }
    }

    for dir_entry in fs::read_dir(&sentry_clips_path).unwrap() {
        let dir_entry = dir_entry.unwrap();
        if let Some(cam_event) = dir_entry_to_cam_event(dir_entry, CamEventKind::SentryClip) {
            events.push(cam_event);
        }
    }

    events.sort_by(|a, b| b.date.cmp(&a.date));

    events
}

fn dir_entry_to_cam_event(dir_entry: DirEntry, event_kind: CamEventKind) -> Option<CamEvent> {
    let path = dir_entry.path().clone();

    if path.is_file() {
        return None;
    }

    let dir_name = dir_entry.file_name().into_string().unwrap();

    let metadata_str = fs::read_to_string(path.join("event.json")).unwrap();
    let metadata: Value = serde_json::from_str(&metadata_str).unwrap();
    let city = metadata["city"].as_str().unwrap().to_string();

    Some(CamEvent {
        date: dir_name_to_date(&dir_name),
        path,
        kind: event_kind,
        location: CamEventLocation { city },
    })
}

fn dir_name_to_date(dir_name: &str) -> String {
    let s: Vec<&str> = dir_name.split('_').collect();
    let d = s[0];
    let t = s[1].replace('-', ":");
    format!("{d} {t}")
}
