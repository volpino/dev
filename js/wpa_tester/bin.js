function isNum(args)
{
    args = args.toString();
    if (args.length == 0)
        return false;

    for (var i = 0;i<args.length;i++)
    {
        if (args.substring(i,i+1) < "0" || args.substring(i, i+1) > "9")
        {
            return false;
        }
    }

    return true;
}
function deciToBin(arg)
{
    res1 = 999;
    args = arg;
    while(args>1)
    {
        arg1 = parseInt(args/2);
        arg2 = args%2;
        args = arg1;
        if(res1 == 999)
        {
            res1 = arg2.toString();
        }
        else
        {
            res1 = arg2.toString()+res1.toString();
        }
    }
    if(args == 1 && res1 != 999)
    {
        res1 = args.toString()+res1.toString();
    }
    else if(args == 0 && res1 == 999)
    {
        res1 = 0;
    }
    else if(res1 == 999)
    {
        res1 = 1;
    }
    var ll = res1.length;
    while(ll%4 != 0)
    {
        res1 = "0"+res1;
        ll = res1.length;
    }
    return res1;
}
function change(name)
{
    var sd = name.value;
    if(isNum(sd))
    {
        var result = deciToBin(sd);
        document.first.deciBin.value = result;
    }
    else
    {
    document.first.deci.value = sd.substring(0,sd.length-1) ;
    }
}

function fill(number, length) {
    var str = '' + number;
    while (str.length < length) {
        str = '0' + str;
    }
    return str;
}

