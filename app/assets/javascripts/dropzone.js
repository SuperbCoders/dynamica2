$(document).bind('dragover', function (e)
{
var dropZone = $('.dropzone'),
    foundDropzone,
    timeout = window.dropZoneTimeout;
    if (!timeout)
    {
        dropZone.addClass('in');
    }
    else
    {
        clearTimeout(timeout);
    }
    var found = false,
    node = e.target;

    do{

        if ($(node).hasClass('dropzone'))
        {
            found = true;
            foundDropzone = $(node);
            break;
        }

        node = node.parentNode;

    }while (node != null);

    dropZone.removeClass('in hover');

    if (found)
    {
        foundDropzone.addClass('hover');
    }

    window.dropZoneTimeout = setTimeout(function ()
    {
        window.dropZoneTimeout = null;
        dropZone.removeClass('in hover');
    }, 100);
});