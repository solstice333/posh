sal e       exit
sal q       exit
sal import  Import-Module
sal remove  Remove-Module
sal new     New-Object

#Remove problematic default aliases
rm -ea 0 `
    alias:curl,
    alias:wget
