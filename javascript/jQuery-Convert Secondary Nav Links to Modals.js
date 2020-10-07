Sys.Application.add_load(openNavItemsInPopup);

function openNavItemsInPopup() {
    jQuery('nav.nav-secondary a[href*="IsPopup=true"]').each(function() {
        // If this isn't set to pop up in a new tab
        if (jQuery(this).attr('target') !== '_blank') {
            jQuery(this).unbind('click');
            jQuery(this).click(function(e,args) {
                // Get the original href URL
                var oldHref = jQuery(this).attr('href');
                ShowDialog_NoReturnValue(oldHref,null,'90%25','90%25',null,null,'E',null,null,false,true,function () { window.location.reload(); },null);
                e.preventDefault();
            });
        }
    });
}
