// jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
(function($){
   $(document).ready(function() {
      // overwrite anchor links
      $("a").each(function() {
        var a = $(this);
        if (a.href) a.href = a.href.replace("#/", "#");
      });
      // overwrite the current url's anchor
      window.location.hash = window.location.hash.replace("#/", "#");
   });
})(jQuery)