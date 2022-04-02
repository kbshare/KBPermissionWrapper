a=$(git rev-parse --abbrev-ref HEAD)

libs="/Users/${USER}/58_ios_libs"

pushd $libs/HouseWBAJKMix
b=$(git rev-parse --abbrev-ref HEAD)
echo "HouseWBAJKMix分支为:${b}"

cd $libs/HouseCommonBusiness
d=$(git rev-parse --abbrev-ref HEAD)
echo "HouseCommonBusiness分支为:${d}"

cd $libs/House
e=$(git rev-parse --abbrev-ref HEAD)
echo "House分支为:${e}"
result=''

loddg() {
     var111=$(
          cat <<-EOF
 "${b}": [\n
            \t"HouseWBAJKMix"\n
], \n
     "${d}": [\n
           \t "HouseCommonBusiness"\n
],\n
     "${e}": [\n
            \t"House"\n
],\n
EOF
     )
     echo 'var内部===='$var111

}
loddg

var=$(
     cat <<-EOF
 "${b}": [\n
            \t"HouseWBAJKMix"\n
], \n
     "${d}": [\n
           \t "HouseCommonBusiness"\n
],\n
     "${e}": [\n
            \t"House"\n
],\n
EOF
)

ddd="

 "${b}": [\n
            \t"HouseWBAJKMix"\n
], \n
     "${d}": [\n
           \t "HouseCommonBusiness"\n
],\n
     "${e}": [\n
            \t"House"\n
],\n"
echo 'ddddddd==='$ddd

echo '---'
echo 'var===='$var
echo '----'

function demofunc() {
     a='&&&&&&&&&&&&'
     echo $a
     return 0
}
echo '-=-=-=-'
demofunc
mun=$?
echo '-=-=-=-'

echo $mun
# cat >>$result <<EOF
#    "\${b}": [\n
#             "HouseWBAJKMix"
#     ],
#      "\${d}": [
#             "HouseCommonBusiness"
#     ],
#      "\${e}": [
#             "House"
#     ],
# EOF

# echo $result
