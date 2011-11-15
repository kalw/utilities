set autolist
if ($?prompt) then        set promptchars = "%#"
        if ($?tcsh) then
                set prompt = "[%m:%c3] %n%# "
        else
                set prompt = "[%m:%c3] `id -nu`%# "        endifendif
set complete = enhance
complete portupgrade 'n@*@D:/var/db/pkg/@'
complete pkg_delete 'n@*@D:/var/db/pkg/@'
complete sudo 'n/-l/u/' 'p/1/c/' 'n@portupgrade@D:/var/db/pkg/@' 'n@pkg_delete@D:/var/db/pkg/@'
complete sysctl 'n/*/`sysctl -Na`/'
complete uncomplete 'p/*/X/'
complete complete 'p/1/c/'
