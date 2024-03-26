type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    console.log("App loaded", app);
    // you can call your custom ports here
    app.ports.sendMessageToJs.subscribe((message) => {
      //app.ports.gotLocalStorage.send(localStorage.getItem(localStorageKey));
      console.log("the message is: ", message);
    });
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};

export default config;
