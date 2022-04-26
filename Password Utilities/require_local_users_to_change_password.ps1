$users = Get-LocalUser
foreach ($user in $users) {
    if ($user.name -ne 'tech-adv') {
        $query = 'Select * from Win32_UserAccount where name LIKE "' + $user.name + '" and localaccount="true"'
        Set-CimInstance -Query $query -Property @{PasswordExpires=$True}
        net user $user.name /logonpasswordchg:yes
    }
}