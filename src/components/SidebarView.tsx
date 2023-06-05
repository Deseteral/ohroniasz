import styled from 'styled-components';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { generatePreviews } from '../services/ipc';

export const SidebarSize = {
  width: '230px',
} as const;

const Column = styled.div`
  display: flex;
  flex-direction: column;
  overflow-y: scroll;
  width: ${SidebarSize.width};
  height: 100vh;
  border-right: 1px solid white;
`;

const CamEventView = styled.div`
  padding: 4px;
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
