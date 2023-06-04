import { invoke } from '@tauri-apps/api/tauri';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';

export async function selectAndScanLibrary(): Promise<CamEvent[]> {
  const events = await invoke('select_and_scan_library');
  return events as CamEvent[];
}

export async function generatePreviews(path: string) {
  await invoke('generate_previews', { path });
}
