import { convertFileSrc } from '@tauri-apps/api/tauri';

interface VideoGridViewProps {

}

function VideoGridView(props: VideoGridViewProps): JSX.Element {
  return (
    <div className="video-grid-container">
      <div className="video-front">
        <video className="video" src={convertFileSrc("/tmp/ohroniasz/front.mp4")} />
      </div>
      <div className="video-back">
        <video className="video" src={convertFileSrc("/tmp/ohroniasz/back.mp4")} />
      </div>
      <div className="video-left">
        <video className="video" src={convertFileSrc("/tmp/ohroniasz/left_repeater.mp4")} />
      </div>
      <div className="video-right">
        <video className="video" src={convertFileSrc("/tmp/ohroniasz/right_repeater.mp4")} />
      </div>
    </div>
  );
}

export { VideoGridView, VideoGridViewProps };
