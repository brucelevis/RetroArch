## lvl. 43 regex dragon awaits thee.
print_help()
{	cat << EOF
====================
 Quickbuild script
====================
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION

General environment variables:
CC:         C compiler
CFLAGS:     C compiler flags
CXX:        C++ compiler
CXXFLAGS:   C++ compiler flags
LDFLAGS:    Linker flags

General options:
--prefix=\$path: Install path prefix
--help: Show this help

Custom options:
EOF
	while IFS='=#' read VAR VAL COMMENT; do
		VAR=$(echo "${VAR##HAVE_}" | tr '[A-Z]' '[a-z]')
		case "$VAL" in
			'yes'*) echo "--disable-$VAR: $COMMENT";;
			'no'*) echo "--enable-$VAR: $COMMENT";;
			'auto'*) echo "--enable-$VAR: $COMMENT"; echo "--disable-$VAR";;
			*) echo "--with-$VAR: $COMMENT";;
		esac
	done < 'qb/config.params.sh'
}

opt_exists() # $opt is returned if exists in OPTS
{
	opt=$(echo "$1" | tr '[a-z]' '[A-Z]')
	for OPT in $OPTS; do [ "$opt" = "$OPT" ] && return; done
	print_help; exit 1
}

parse_input() # Parse stuff :V
{
	#OPTS contains all available options in config.params.sh
	while IFS='=' read VAR dummy; do OPTS="$OPTS ${VAR##HAVE_}"; done < 'qb/config.params.sh'
	
	while [ "$1" ]; do
		case "$1" in
			--prefix=*) PREFIX=${1##--prefix=};;

			--enable-*)
				opt_exists "${1##--enable-}" "$OPTS"
				eval "HAVE_$opt=yes"
			;;

			--disable-*)
				opt_exists "${1##--disable-}" "$OPTS"
				eval "HAVE_$opt=no"
			;;

			--with-*)
				arg=${1##--with-}
				val=${arg##*=}
				opt_exists "${arg%%=*}" "$OPTS"
				eval "$opt=$val"
			;;

			-h|--help) print_help; exit 0;;

			*) print_help; exit 1;;
		esac
		shift
	done
}

. qb/config.params.sh

parse_input "$@"

 
