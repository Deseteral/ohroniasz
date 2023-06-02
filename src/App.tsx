import { convertFileSrc } from '@tauri-apps/api/tauri';

interface AppProps {

}

function App(props: AppProps): JSX.Element {
  return (
    <div className="video-grid-container">
      <div className="video video-front">
        <video src={convertFileSrc("/tmp/ohroniasz/front.mp4")} />
      </div>
      <div className="video video-back">
        <video src={convertFileSrc("/tmp/ohroniasz/back.mp4")} />
      </div>
      <div className="video video-left">
        <video src={convertFileSrc("/tmp/ohroniasz/left_repeater.mp4")} />
      </div>
      <div className="video video-right">
        <video src={convertFileSrc("/tmp/ohroniasz/right_repeater.mp4")} />
      </div>
    </div>
  );
}

export { App, AppProps };
