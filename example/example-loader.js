
function getJsonObject(jsonFile)
{
    var xmlhttp = new XMLHttpRequest();
    var jsonObject;

    xmlhttp.onreadystatechange = function()
    {
        if (this.readyState == 4 && this.status == 200)
            jsonObject = JSON.parse(this.responseText);
        else
            jsonObject = null;
    }
    xmlhttp.open("GET", jsonFile, false);
    xmlhttp.send();
    return jsonObject;
}

function getEditorFromPalette(paletteFile)
{
    mode = getJsonObject(paletteFile);
    editor = new droplet.Editor(document.getElementById('editor'), mode);
    document.getElementById('toggle').addEventListener('click', function() { editor.toggleBlocks(); });
    return editor;
}

