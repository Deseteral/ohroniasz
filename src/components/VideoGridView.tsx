import { convertFileSrc } from '@tauri-apps/api/tauri';
import React from 'react';
import styled from 'styled-components';
import { SidebarSize } from './SidebarView';

enum TilePosition {
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
}

const Container = styled.div`
  width: calc(100vw - ${SidebarSize.width});
  height: 100vh;
`;

const Column = styled.div`
  display: flex;
  flex-direction: column;
`;

const Grid = styled.div`
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  grid-column-gap: 0px;
  grid-row-gap: 0px;
`;

const ControlsBar = styled.div`
  display: flex;
  flex-direction: row;
  margin: 16px;
  padding: 8px;
  border: 2px solid white;
  border-radius: 4px;
`;

const VideoTile = styled.video<{ position: TilePosition }>`
  width: 100% !important;
  height: auto !important;

  ${(({ position }) => {
    switch (position) {
      case TilePosition.TOP_LEFT: return 'grid-area: 1 / 1 / 2 / 2;';
      case TilePosition.TOP_RIGHT: return 'grid-area: 1 / 2 / 2 / 3;';
      case TilePosition.BOTTOM_LEFT: return 'grid-area: 2 / 1 / 3 / 2;';
      case TilePosition.BOTTOM_RIGHT: return 'grid-area: 2 / 2 / 3 / 3;';
      default: return '';
    }
  })}
`;

const PlayPauseButton = styled.button.attrs(() => ({
  type: 'button',
}))`
  background-color: red;
`;

const TimeSlider = styled.input.attrs(() => ({
  type: 'range',
  min: 0,
  step: 0.01,
}))`
  width: 100%;
`;

interface VideoGridViewProps {

}

function VideoGridView(props: VideoGridViewProps): JSX.Element {
  const videoFront = React.useRef<HTMLVideoElement>(null);
  const videoBack = React.useRef<HTMLVideoElement>(null);
  const videoLeft = React.useRef<HTMLVideoElement>(null);
  const videoRight = React.useRef<HTMLVideoElement>(null);

  const [timeSliderValue, setTimeSliderValue] = React.useState<number>(0);
  const [videoLength, initializeVideoLength] = React.useState<number>(0);

  const actOnAllVideoTiles = (callback: (video: HTMLVideoElement) => void) => {
    if (videoFront.current) callback(videoFront.current);
    if (videoBack.current) callback(videoBack.current);
    if (videoLeft.current) callback(videoLeft.current);
    if (videoRight.current) callback(videoRight.current);
  };

  const togglePlayState = () => {
    if (videoFront.current?.paused) {
      actOnAllVideoTiles((video) => video.play());
    } else {
      actOnAllVideoTiles((video) => video.pause());
    }
  };

  const userChangedSliderValue = (position: number) => {
    setTimeSliderValue(position);
    actOnAllVideoTiles((video) => {
      video.pause();
      video.currentTime = position;
    });
  };

  return (
    <Container>
      <Column>
        <Grid>
          <VideoTile
            position={TilePosition.TOP_LEFT}
            src={convertFileSrc('/tmp/ohroniasz/front.mp4')}
            onTimeUpdate={() => setTimeSliderValue(videoFront.current?.currentTime || 0)}
            onLoadedData={() => initializeVideoLength(videoFront.current?.duration || 0)}
            ref={videoFront}
          />
          <VideoTile
            position={TilePosition.TOP_RIGHT}
            src={convertFileSrc('/tmp/ohroniasz/back.mp4')}
            ref={videoBack}
          />
          <VideoTile
            position={TilePosition.BOTTOM_LEFT}
            src={convertFileSrc('/tmp/ohroniasz/left_repeater.mp4')}
            ref={videoLeft}
          />
          <VideoTile
            position={TilePosition.BOTTOM_RIGHT}
            src={convertFileSrc('/tmp/ohroniasz/right_repeater.mp4')}
            ref={videoRight}
          />
        </Grid>
        <ControlsBar>
          <PlayPauseButton onClick={() => togglePlayState()}>play</PlayPauseButton>
          <TimeSlider
            max={videoLength}
            value={timeSliderValue}
            onChange={(e) => userChangedSliderValue(parseFloat(e.target.value))}
          />
        </ControlsBar>
      </Column>
    </Container>
  );
}

export { VideoGridView, VideoGridViewProps };
