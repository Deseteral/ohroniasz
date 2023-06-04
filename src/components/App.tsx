import { VideoGridView } from './VideoGridView';
import { WelcomeView } from './WelcomeView';

interface AppProps {

}

function App(props: AppProps): JSX.Element {
  return (
    <>
      <WelcomeView />
      {false && <VideoGridView />}
    </>
  );
}

export { App, AppProps };
