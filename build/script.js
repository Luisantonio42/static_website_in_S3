document.getElementById("year").textContent = new Date().getFullYear();

const toggle = document.getElementById("themeToggle");
toggle.addEventListener("click", () => {
  document.documentElement.classList.toggle("light");
});
