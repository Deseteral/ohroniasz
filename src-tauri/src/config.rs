use std::fs;

pub static WORKING_DIR_PATH: &str = "/tmp/ohroniasz";

pub fn create_working_dir() {
    fs::create_dir_all(WORKING_DIR_PATH).expect("Could not create app working directory");
}
