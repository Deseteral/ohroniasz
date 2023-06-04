import React from 'react';
import styled from 'styled-components';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { VideoGridView } from './VideoGridView';
import { WelcomeView } from './WelcomeView';
import { SidebarView } from './SidebarView';

const Row = styled.div`
  display: flex;
  flex-direction: row;
`;

interface AppProps {

}

function App(props: AppProps): JSX.Element {
  const [camEvents, setCamEvents] = React.useState<CamEvent[] | null>(null);
  const [wasEventSelected, setEventSelected] = React.useState<boolean>(false);

  return (
    <>
      {camEvents === null && (
        <WelcomeView onLibraryLoaded={(events) => setCamEvents(events)} />
      )}
      {camEvents !== null && (
        <Row>
          <SidebarView
            events={camEvents}
            onSelectedEventChange={() => setEventSelected(false)}
            onPreviewGenerationFinished={() => setEventSelected(true)}
          />
          {wasEventSelected && <VideoGridView />}
        </Row>
      )}
    </>
  );
}

export { App, AppProps };
