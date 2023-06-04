import React from 'react';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { VideoGridView } from './VideoGridView';
import { WelcomeView } from './WelcomeView';

interface AppProps {

}

function App(props: AppProps): JSX.Element {
  const [camEvents, setCamEvents] = React.useState<CamEvent[] | null>(null);

  return (
    <>
      <WelcomeView onLibraryLoaded={(events) => setCamEvents(events)} />
      {false && <VideoGridView />}
    </>
  );
}

export { App, AppProps };
