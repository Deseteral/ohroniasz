import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { selectAndScanLibrary } from '../services/ipc';

interface WelcomeViewProps {
  onLibraryLoaded: (events: CamEvent[]) => void,
}

function WelcomeView({ onLibraryLoaded }: WelcomeViewProps): JSX.Element {
  const selectLibrary = async () => {
    const events = await selectAndScanLibrary();
    onLibraryLoaded(events);
  };

  return (
    <div>
      <button type="button" onClick={() => selectLibrary()}>
        select
      </button>
    </div>
  );
}

export { WelcomeView, WelcomeViewProps };
