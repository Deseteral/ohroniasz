import styled from 'styled-components';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';

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
  onEventSelected: () => void,
}

function SidebarView({ events, onEventSelected }: SidebarViewProps): JSX.Element {
  const onEventClick = (event: CamEvent) => {
    onEventSelected();
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
