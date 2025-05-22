function info
    set pkg $argv[1]
    if xbps-query -l | awk '{print $2}' | grep -qw $pkg
        xbps-query -S $pkg | awk -v pkg="$pkg" '
            /^pkgname:/ {pkgname="\033[1mPackage name:\033[0m " substr($0, index($0, ":") + 2); next}
            /^pkgver:/ {pkgver="\033[1mVersion:\033[0m " substr($0, index($0, ":") + 2); next}
            /^short_desc:/ {short_desc="\033[1mDescription:\033[0m " substr($0, index($0, ":") + 2); next}
            /^repository:/ {repository="\033[1mRepository:\033[0m " substr($0, index($0, ":") + 2); next}
            /^filename-size:/ {filename_size="\033[1mFile size:\033[0m " substr($0, index($0, ":") + 2); next}
            /^installed_size:/ {installed_size="\033[1mInstalled size:\033[0m " substr($0, index($0, ":") + 2); next}
            /^maintainer:/ {maintainer="\033[1mMaintainer:\033[0m " substr($0, index($0, ":") + 2); next}
            /^state:/ {state="\033[1mState:\033[0m " substr($0, index($0, ":") + 2); next}
            END {
                if (pkgname) {
                    print pkgname
                    print pkgver
                    print short_desc
                    print repository
                    print filename_size
                    print installed_size
                    print maintainer
                    if (state) print state
                } else {
                    print "Package \"" pkg "\" is not found."
                }
            }'
    else
        xbps-query -RS $pkg | awk -v pkg="$pkg" '
            /^pkgname:/ {pkgname="\033[1mPackage name:\033[0m " substr($0, index($0, ":") + 2); next}
            /^pkgver:/ {pkgver="\033[1mVersion:\033[0m " substr($0, index($0, ":") + 2); next}
            /^short_desc:/ {short_desc="\033[1mDescription:\033[0m " substr($0, index($0, ":") + 2); next}
            /^repository:/ {repository="\033[1mRepository:\033[0m " substr($0, index($0, ":") + 2); next}
            /^filename-size:/ {filename_size="\033[1mFile size:\033[0m " substr($0, index($0, ":") + 2); next}
            /^installed_size:/ {installed_size="\033[1mInstalled size:\033[0m " substr($0, index($0, ":") + 2); next}
            /^maintainer:/ {maintainer="\033[1mMaintainer:\033[0m " substr($0, index($0, ":") + 2); next}
            END {
                if (pkgname) {
                    print pkgname
                    print pkgver
                    print short_desc
                    print repository
                    print filename_size
                    print installed_size
                    print maintainer
                } else {
                    print "Package \"" pkg "\" is not found."
                }
            }'
    end
end
