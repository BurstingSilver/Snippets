<!-- BEGIN Prevent iMIS/AngularJS Location Provider from breaking the anchor links -->
<!-- Place this script near the end of the body in the master page -->
<script type="text/javascript">
   // iMIS 20.2.49 fix for AngularJS $location adding a forward slash in anchor links
   // ie.:	before:	https://site.com/WEB/Regions.aspx#SK
   //  	after:	https://site.com/WEB/Regions.aspx#/SK
   // jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
   (function($){
      $(document).ready(function() {
        angular.module('app')
            .config(function ($locationProvider) {
              $locationProvider.html5Mode({
                  enabled: true,
                  rewriteLinks: false
               });
         });

        $("a").each(function() {
         var a = $(this);
         if (a.href) a.href = a.href.replace("#/", "#");
        });
      });
   })(jQuery)
 </script>
<!-- END -->
