import styled from 'styled-components';
import { CamEvent } from '../../src-tauri/bindings/CamEvent';
import { selectAndScanLibrary } from '../services/ipc';

const Container = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
`;

const ContentContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  width: 400px;
`;

const Text = styled.span<{ italic?: boolean, center?: boolean }>`
  font-style: ${({ italic }) => (italic ? 'italic' : 'normal')};
  ${({ center }) => (center ? 'text-align: center;' : '')}
`;

const Button = styled.button.attrs(() => ({
  type: 'button',
}))`
  background: none;
  background-color: var(--color-main);
  color: white;
  padding: 8px;
  border: none;
  border-radius: 4px;
  font-family: "Berkeley Mono";
  font-size: 14px;
  cursor: pointer;
  transition: background-color .3s ease-in-out;

  &:hover {
    background-color: var(--color-main-darker);
  }
`;

interface WelcomeViewProps {
  onLibraryLoaded: (events: CamEvent[]) => void,
}

function WelcomeView({ onLibraryLoaded }: WelcomeViewProps): JSX.Element {
  const selectLibrary = async () => {
    const events = await selectAndScanLibrary();
    onLibraryLoaded(events);
  };

  return (
    <Container>
      <ContentContainer>
        <Text center>
          Open <Text italic>TeslaCam</Text> directory with the footage you would like to watch.
        </Text>

        <Button onClick={() => selectLibrary()}>Select</Button>
      </ContentContainer>
    </Container>
  );
}

export { WelcomeView, WelcomeViewProps };
