const audioPlayer = new Howl({ src: ["sound.mp3"], volume: 0.15 });

window.addEventListener("message", (event) => {
  if (event.data.sound) {
    audioPlayer.play();
  }
});
