// Must include Jquery
// Or rewrite to use pure JS
// $(document).ready(function() {
//
//   function revealStacktrace() {
//     $(".occurrence-details").addClass("hidden")
//     $(window.location.hash).removeClass("hidden")
//     $(".reveal-occurrence").removeClass("selected")
//
//     if (window.location.hash == "") {
//       $(".occurrence-details").first().removeClass("hidden")
//     } else {
//       $(".reveal-occurrence[href='" + window.location.hash + "']").addClass("selected")
//     }
//   }
//   revealStacktrace()
//
//   $(".reveal-occurrence").click(function() {
//     // We want the hash/anchor to be updated before running the function
//     setTimeout(revealStacktrace, 100)
//   })
//
//   $(".open-compressed").click(function(evt) {
//     evt.preventDefault()
//     $("[data-wrapname=" + $(this).attr("data-target") + "]").toggleClass("open")
//   })
//
//   $(".update-dropdown").change(function(evt) {
//     var report_data = { bug_report: {} }
//     report_data.bug_report[$(this).attr("data-name")] = $(this).val()
//
//     $.ajax({
//       method: "PATCH",
//       url: $(this).attr("data-url"),
//       data: report_data,
//       dataType: "json"
//     })
//   })
// })
