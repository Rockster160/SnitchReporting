document.addEventListener("DOMContentLoaded", function(){
  document.querySelector("[name=filter_string]").addEventListener("focus", function(event) {
    document.querySelector(".filters").classList.add("open")
  })

  setNewFilters(document.querySelector("[name=filter_string]").value)
});

document.addEventListener("click", function(event) {
  if (event.target.matches(".filters") || event.target.matches("[name=filter_string]")) {
    return event.stopPropagation()
  }

  if (event.target.matches(".filter-cell")) {
    event.preventDefault()
    return applyFilter(event.target)
  }

  document.querySelector(".filters").classList.remove("open")
})

function applyFilter(selected_cell) {
  var filter_field = document.querySelector("[name=filter_string]")
  var filter_string = filter_field.value

  var matched_filters = filter_string.match(new RegExp(selected_cell.dataset.filterName + ":" + "\\w+"))
  var current_filter = (matched_filters || [])[0]

  if (current_filter == undefined) {
    current_filter = selected_cell.dataset.filterName + ":" + selected_cell.dataset.filterValue

    if (!filter_string.slice(-1) == " ") { filter_string = filter_string + " " }
    filter_string = filter_string + current_filter
  } else {
    var filter_values = current_filter.split(":")
    var filter_name = filter_values[0]
    var filter_value = filter_values[1]
    var filter_sort = filter_values[2]

    var new_filter = current_filter.replace(filter_value, selected_cell.dataset.filterValue)

    filter_string = filter_string.replace(current_filter, new_filter)
  }

  setNewFilters(filter_string)
}

function setNewFilters(filter_string) {
  var filter_field = document.querySelector("[name=filter_string]")
  filter_field.value = filter_string

  var filters = {}, filter_strings = filter_string.match(/\w+\:\w+/g) || []
  filter_strings.forEach(function(filter) {
    var filter_values = filter.split(":")
    var filter_name = filter_values[0]
    var filter_value = filter_values[1]
    var filter_sort = filter_values[2]

    filters[filter_name] = filter_value
  })

  document.querySelectorAll(".filters .snitch-table").forEach(function(filter_table) {
    var current_filter = filters[filter_table.dataset.filterName]
    current_filter = current_filter || filter_table.dataset.default

    filter_table.querySelectorAll(".filter-cell").forEach(function(filter_cell) {
      if (filter_cell.dataset.filterValue == current_filter) {
        filter_cell.classList.add("selected")
      } else {
        filter_cell.classList.remove("selected")
      }
    })
  })
}
