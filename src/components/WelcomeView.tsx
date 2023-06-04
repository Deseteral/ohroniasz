import { invoke } from '@tauri-apps/api/tauri';

interface WelcomeViewProps {

}

function WelcomeView(props: WelcomeViewProps): JSX.Element {
  const selectLibrary = () => {
    invoke('select_library').then((res) => console.log(res));
  };

  return (
    <div>
      <button type="button" onClick={() => selectLibrary()}>
        select
      </button>
    </div>
  );
}

export { WelcomeView, WelcomeViewProps };
