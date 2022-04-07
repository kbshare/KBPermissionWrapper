#!/bin/bash

## 到项目跟目录执行该脚本
ST_COMMIT_MSG=".stCommitMsg"

COMMIT_MSG="commit-msg"
GIT_HOOKS=".git/hooks"
GIT_COMMIT_MSG="$GIT_HOOKS/$COMMIT_MSG"
FIRST_DO="0"
INSTALL='install'
UNINSTALL="uninstall"

whiteFile() {
    echo $1
    if [ $1 ]; then
        #下面是模板,不满足可自行修改
        cat >>$ST_COMMIT_MSG <<EOF
EOF
    else
        #下面是模板,不满足可自行修改
        cat >>$ST_COMMIT_MSG <<EOF
▶︎改动所属类型(type):
▶︎改动所属模块(scope):
▶︎改动具体描述(subject):

⚠️ 提交时以下内容均不用删除
❤️ 不知道怎么用 看下面文档👇👇👇 

示例: 
改动所属类型(type): feat
改动所属模块(scope): 登录
改动具体描述(subject): 增加短信验证码登录

最后生成提交信息为:  feat(登录): 增加短信验证码登录

type 改动所属类型
       feat :新功能
	fix :修复bug
	opt :优化(optimize) 图片压缩, 文件删除等
	ci : 版本号升级、branchConfig修改、scrip/podinfo.rb等发布相关修改
	test :增加测试

	refactor :某个已有功能重构
	docs :文档改变
	style :代码格式改变
	revert :撤销上一次的 commit (revert 命令自动生成)

scope 改动所属模块, 用来说明此次修改的影响范围 (最好自己定义, 如改动了租房详情页, 直接写租房详情页即可)
 	all :表示影响面大 ，如修改了网络框架  会对真个程序产生影响
 	loation :表示影响小，某个小小的功能
	module :表示会影响某个模块 如登录模块、首页模块 、用户管理模块等等

subject: 用来简要信息描述本次改动
EOF
    fi
}

#全局模板
installGitRules() {

    # pushd ~/
    # if [ ! -f $ST_COMMIT_MSG ]; then
    #     echo "$ST_COMMIT_MSG file not exist"
    #     touch .stCommitMsg
    #     whiteFile $1
    # else
    #     COPY_FILE="${ST_COMMIT_MSG}_backup"
    #     # echo "has $ST_COMMIT_MSG file"
    #     cp -P ~/$ST_COMMIT_MSG ~/$COPY_FILE
    #     : >$ST_COMMIT_MSG
    #     whiteFile $1
    # fi
    # popd
    writeCommitMsg() {
        # echo "准备写入文件"
        cat >>.git/hooks/commit-msg <<EOF
#!/bin/bash
export LANG="en_US.UTF-8"
TIP_MESSAGE='
<type>(<scope>) : <subject>\n
<body>\n
<footer>\n
\n
#type 本次修改功能类型\n
    .feat :新功能\n
    .fix :修复bug\n
    .opt :优化(optimize) 图片压缩, 文件删除等\n
    .ci : 版本号升级、branchConfig修改、scrip/podinfo.rb等发布相关修改\n
    .test :增加测试\n

    .refactor :某个已有功能重构\n
    .docs :文档改变\n
    .style :代码格式改变\n
    .revert :撤销上一次的 commit (revert 命令自动生成)\n
\n
#scope :用来说明此次修改的影响范围\n
    .all :表示影响面大 ，如修改了网络框架  会对真个程序产生影响\n
    .loation :表示影响小，某个小小的功能\n
    .module :表示会影响某个模块 如登录模块、首页模块 、用户管理模块等等\n
\n
#subject: 用来简要信息描述本次改动\n
\n
#body :具体的修改信息 应该尽量详细\n
\n
#footer :备注:  文档链接、bug id、设计文档\n
'

MSG=\$(awk '{printf("%s",\$0)}' \$1)
subMsg=$(echo \${MSG%⚠️ *})
subMsg=\$(echo \$subMsg | xargs echo -n)
subMsg=\$(echo \$subMsg | sed s/[[:space:]]//g)
OLD_IFS="\$IFS"
IFS="▶︎"
array=(\$subMsg)
IFS="\$OLD_IFS"
completeStr=''
c=0
for s in \${array[@]}; do
    c=\$((\$c + 1))
    subStr=\${s##*:}
    if [ \$c == 1 ]; then
        completeStr=\$subStr
    elif [ \$c == 2 ]; then
        completeStr="\${completeStr}(\$subStr):"
    elif [ \$c == 3 ]; then
        completeStr="\${completeStr}\$subStr"
    fi
done

if [ -n array ]; then
    if [ \${#array[*]} -le 1 ]; then
        completeStr=\$MSG
    fi
fi

if [[ \$completeStr =~ ^(feat|fix|opt|ci|test|refactor|docs|style|revert)\(.*\):.*$ ]]; then
    echo -e " commit success!"
    echo "\$completeStr" >"\$1"
else
    echo -e " Error: the commit message is irregular "
    echo -e " Error: type must be one of feat|fix|opt|ci|test|refactor|docs|style|revert"
    echo -e ' eg: feat(租房): 详情页增加无尽流'
    echo '详细文档👇👇👇'
    echo -e \$TIP_MESSAGE
    exit 1
fi
EOF
    }

    if [ ! -d $GIT_HOOKS ]; then
        pushd .git
        mkdir hooks
        mkfile -n 0b hooks/commit-msg
        popd
        writeCommitMsg
    else
        # echo "has hooks folder"
        if [ ! -f $GIT_COMMIT_MSG ]; then
            # pwd
            # echo "$COMMIT_MSG not exist"
            mkfile -n 0b $GIT_COMMIT_MSG
            writeCommitMsg
        else
            # echo "has ${COMMIT_MSG} file"
            # pwd
            COPY_FILE="${COMMIT_MSG}_backup"
            cp -P $GIT_COMMIT_MSG $GIT_HOOKS/$COPY_FILE
            : >$GIT_COMMIT_MSG
            writeCommitMsg
        fi
    fi

    sudo chmod 777 $GIT_COMMIT_MSG
    if [ $FIRST_DO != '0' ]; then
        echo 'Configuration is successful! 👏👏👏 '
        echo 'Restart Sourcetree then submit your changes!'
    fi
}

# 卸载钩子和模板
function uninstallGitRules() {
    if [ ! -f $GIT_COMMIT_MSG ]; then
        echo "Don't have git commit message rules to remove!"
    else
        rm $GIT_COMMIT_MSG
        echo "remove git commit message rules success!"
    fi

    pushd ~/
    if [ ! -f $ST_COMMIT_MSG ]; then
        echo "$ST_COMMIT_MSG file not exist, Don't have git commit rules template to remove!  Maybe removed already early"
    else
        rm $ST_COMMIT_MSG
        echo "remove git commit message rules template success!"
    fi
    popd

}

# 安装 生效
function installTakeEffect() {
    installGitRules $1
    FIRST_DO="1"
    installGitRules $1
}

function nothing() {
    THING=''
}

function getDirInstallOrUninstall() {
    DO=$2
    for element in $(ls -a $1); do
        if [ $element == ".git" ]; then
            pushd $1
            if [ $DO == ${UNINSTALL} ]; then
                uninstallGitRules
            else
                installTakeEffect
            fi
            popd
        else
            if [ -d $1"/"$element ]; then

                if [[ $element == .* ]] || [[ $element == ..* ]]; then
                    nothing #排除系统 . .. 文件夹
                else
                    getDirInstallOrUninstall $1"/"$element $DO
                fi
            fi
        fi
    done

}

helpFunc() {
    echo -e "install 安装默认提交模板"
    echo -e "uninstall 卸载提交模板和规范钩子 "
    echo -e "uninstallTemp 卸载默认提交模板,保留规范钩子"
    echo -e "installAll 为目录中所有包含 git 的项目添加规范钩子和提交模板"
    echo -e "uninstallAll 为目录中所有包含 git 的项目卸载规范钩子和提交模板"
}

if [ $# -eq 0 ]; then
    installTakeEffect
else
    for i in "$*"; do
        if [ $i == "install" ]; then
            installTakeEffect
        elif [ $i == "uninstallTemp" ]; then
            installTakeEffect 'easy'
        elif [ $i == "uninstall" ]; then
            uninstallGitRules
        elif [ $i == "installAll" ]; then
            getDirInstallOrUninstall $(pwd) ${INSTALL}
        elif [ $i == "uninstallAll" ]; then
            getDirInstallOrUninstall $(pwd) ${UNINSTALL}
        elif [ $i == "help" ]; then
            helpFunc
        fi
    done
fi
