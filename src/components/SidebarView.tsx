import styled from 'styled-components';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { generatePreviews } from '../services/ipc';

const Column = styled.div`
  display: flex;
  flex-direction: column;
  overflow-y: scroll;
`;

const CamEventView = styled.div`
  border-bottom: 1px solid gray;
  cursor: pointer;
`;

interface SidebarViewProps {
  events: CamEvent[],
  onSelectedEventChange: () => void,
  onPreviewGenerationFinished: () => void,
}

function SidebarView({ events, onSelectedEventChange, onPreviewGenerationFinished }: SidebarViewProps): JSX.Element {
  const onEventClick = async (event: CamEvent) => {
    onSelectedEventChange();
    await generatePreviews(event.path);
    onPreviewGenerationFinished();
  };

  return (
    <Column>
      {events.map((event) => (
        <CamEventView key={event.date} onClick={() => onEventClick(event)}>
          <div>{event.date}</div>
          <div>{event.kind}</div>
        </CamEventView>
      ))}
    </Column>
  );
}

export { SidebarView, SidebarViewProps };
