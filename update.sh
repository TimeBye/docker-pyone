#!/bin/bash
update_config(){
    num=`cat config.py | grep "show_secret" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'show_secret="no"' >> config.py
    fi

    num=`cat config.py | grep "encrypt_file" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'encrypt_file="no"' >> config.py
    fi

    num=`cat config.py | grep "headCode" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'headCode=""""""' >> config.py
    fi

    num=`cat config.py | grep "footCode" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'footCode=""""""' >> config.py
    fi

    num=`cat config.py | grep "cssCode" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'cssCode=""""""' >> config.py
    fi

    num=`cat config.py | grep "title_pre" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'title_pre=""' >> config.py
    fi

    num=`cat config.py | grep "theme" | wc -l`
    if [ $num == 0 ]; then
        echo '' >> config.py
        echo 'theme=""' >> config.py
    fi
}
update_config