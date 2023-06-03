import { convertFileSrc } from '@tauri-apps/api/tauri';
import React from 'react';

interface VideoGridViewProps {

}

function VideoGridView(props: VideoGridViewProps): JSX.Element {
  const videoFront = React.useRef<HTMLVideoElement>(null);
  const videoBack = React.useRef<HTMLVideoElement>(null);
  const videoLeft = React.useRef<HTMLVideoElement>(null);
  const videoRight = React.useRef<HTMLVideoElement>(null);

  const play = () => {
    videoFront.current?.play();
    videoBack.current?.play();
    videoLeft.current?.play();
    videoRight.current?.play();
  };

  return (
    <div className="video-grid-container">
      <div className="column">
        <div className="video-grid">
          <div className="video-front">
            <video className="video" src={convertFileSrc("/tmp/ohroniasz/front.mp4")} ref={videoFront} />
          </div>
          <div className="video-back">
            <video className="video" src={convertFileSrc("/tmp/ohroniasz/back.mp4")} ref={videoBack} />
          </div>
          <div className="video-left">
            <video className="video" src={convertFileSrc("/tmp/ohroniasz/left_repeater.mp4")} ref={videoLeft} />
          </div>
          <div className="video-right">
            <video className="video" src={convertFileSrc("/tmp/ohroniasz/right_repeater.mp4")} ref={videoRight} />
          </div>
        </div>
        <div>
          <button onClick={() => play()}>play</button>
        </div>
      </div>
    </div>
  );
}

export { VideoGridView, VideoGridViewProps };
