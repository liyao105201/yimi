#!/bin/bash

show_usage(){
    cat <<EOF
    Usage:
      -S <svn-version>      svn版本号，默认是用HEAD版本作为版本
      -G <git-version>      git版本号，默认使用 Git master HEAD版本
      -b <branch>           git分支 默认是master
      -n <project-version>  指定的版本号： 必须指明如 "2.5"
      -v                    version
      -h                    Helper for shell.
EOF
}
show_version()
{
    echo "version: 1.0"
    echo "updated date: 2019-09-01"
}

init(){
# 入口参数分析
TEMP=`getopt -o hvVn:S:G:b: --long help,version,name:,svn:,git:,branch: -- "$@" 2>/dev/null`

if [[ $? != 0 ]]; then
    echo -e "\033[31mERROR: unknown argument! \033[0m\n"
    show_usage
    exit 1
fi

# 会将符合getopt参数规则的参数摆在前面，其他摆在后面，并在最后面添加--
eval set -- "${TEMP}"
while :
do
    [[ -z "$1" ]] && break;
    case "$1" in
        -h|--help)
            show_usage; exit 0
        ;;
        -v|-V|--version)
            show_version; exit 0
        ;;
        -G|--git)
            GIT_VERSION=$2; shift 2
        ;;
        -S|--svn)
            SVN_VERSION=$2; shift 2
        ;;
        -b|--branch)
            GIT_BRANCH=$2; shift 2
        ;;
        -n|--name)
            IMAGE_NAME=$2; shift 2
        ;;
        --)
            shift
            ;;
        *)
         echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1
         ;;
       esac
done
}


init $@