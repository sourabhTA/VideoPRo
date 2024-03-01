$(document).ready(function() {
    if($('#gmaps-input-address').length > 0){
        $('#gmaps-input-address').geocomplete();
    }
});