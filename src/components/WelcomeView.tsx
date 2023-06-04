import { invoke } from '@tauri-apps/api/tauri';

interface WelcomeViewProps {

}

function WelcomeView(props: WelcomeViewProps): JSX.Element {
  const selectDirectory = () => {
    invoke('select_directory').then((res) => console.log(res));
  };

  return (
    <div>
      <button type="button" onClick={() => selectDirectory()}>
        select
      </button>
    </div>
  );
}

export { WelcomeView, WelcomeViewProps };
