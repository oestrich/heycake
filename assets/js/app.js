// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

import 'jquery';

import '@fortawesome/fontawesome-free/js/fontawesome';
import '@fortawesome/fontawesome-free/js/solid';
import '@fortawesome/fontawesome-free/js/regular';
import '@fortawesome/fontawesome-free/js/brands';

import "phoenix_html";

import EmojiConvertor from 'emoji-js';

window.addEventListener("DOMContentLoaded", () => {
  let emojiConverter = new EmojiConvertor();

  emojiConverter.img_sets.apple.path = 'https://raw.githubusercontent.com/iamcal/emoji-data/master/img-apple-64/';

  document.querySelectorAll(".emoji-replace").forEach((el) => {
    let emoji = emojiConverter.replace_colons(el.innerHTML);
    el.innerHTML = emoji;
  });
});
