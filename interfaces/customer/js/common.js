function checkValue(element) {
    // check if the input has any value (if we've typed into it)
    if ($(element).val())
        $(element).addClass('has-value');
    else
        $(element).removeClass('has-value');
}

$(document).ready(function() {
    // Run on page load
    $('.form-control').each(function() {
        checkValue(this);
    })
    // Run on input exit
    $('.form-control').blur(function() {
        checkValue(this);
    });

});