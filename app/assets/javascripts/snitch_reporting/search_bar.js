document.addEventListener("DOMContentLoaded", function(){
  document.querySelector("[name=filter_string]").addEventListener("focus", function(event) {
    document.querySelector(".filters").classList.add("open")
  })
});

document.addEventListener("click", function(event) {
  if (event.target.matches(".close-filters")) {
    document.querySelector(".filters").classList.remove("open")
  }
})
