/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,js,vue}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
module.exports = {
  theme: {
    extend: {
      colors: {
        darkGray: "#1c1e26",
        darkPurple: "#3a2f70",
        lightPurple: "#d8ccf9",
      },
    },
  },
};
