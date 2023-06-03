import { convertFileSrc } from '@tauri-apps/api/tauri';
import React from 'react';
import styled from 'styled-components';

enum TilePosition {
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
}

const Container = styled.div`
  width: 100vw;
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

interface VideoGridViewProps {

}

function VideoGridView(props: VideoGridViewProps): JSX.Element {
  const videoFront = React.useRef<HTMLVideoElement>(null);
  const videoBack = React.useRef<HTMLVideoElement>(null);
  const videoLeft = React.useRef<HTMLVideoElement>(null);
  const videoRight = React.useRef<HTMLVideoElement>(null);

  const play = () => {
    if (videoFront.current?.paused) {
      videoFront.current?.play();
      videoBack.current?.play();
      videoLeft.current?.play();
      videoRight.current?.play();
    } else {
      videoFront.current?.pause();
      videoBack.current?.pause();
      videoLeft.current?.pause();
      videoRight.current?.pause();
    }
  };

  return (
    <Container>
      <Column>
        <Grid>
          <VideoTile
            position={TilePosition.TOP_LEFT}
            src={convertFileSrc('/tmp/ohroniasz/front.mp4')}
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
        <div>
          <button onClick={() => play()} type="button">play</button>
        </div>
      </Column>
    </Container>
  );
}

export { VideoGridView, VideoGridViewProps };
