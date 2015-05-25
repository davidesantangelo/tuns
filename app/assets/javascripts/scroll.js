$(window).scroll(function() {
 if ($(this).scrollTop() > 250) {
    $('#toTop').fadeIn();
  } else {
    $('#toTop').fadeOut();
  }
});
